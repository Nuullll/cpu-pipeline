# cpu-pipeline **完结**
数字逻辑与处理器基础夏季学期 - **CPU流水线**

## 流水线结构

### `IF` (Instruction Fetch)

- 从`InstructionMemory`(`ROM`)中抓取指令

- 在下个时钟沿将**指令**和`PC+4`写入`IF/ID`寄存器

### `ID` (Instruction Decode)

- 从`IF/ID`中获取指令进行译码

- 利用`Control`模块产生控制信号

- 计算分支指令的目标地址(**提前分支指令**)

- 计算跳转指令的目标地址

- 判断分支指令跳转条件

    + 跳转时通过`flush_IF_ID`控制信号清空`IF/ID`寄存器(即丢弃上一条指令)

- 进行**冒险检测**

    + 需求

        - `EX_MemRead`: 上一条指令的`MemRead`

    + 冒险条件成立时产生`bubble`信号, 清空`ID/EX`, 插入一个流水线气泡

        - 冒险条件(同时满足以下两条则冒险成立)

            1. `EX_MemRead == 1`: 上一条指令(`EX`阶段指令)是`lw`

            2. `EX_WriteRegister == ID_Rs || EX_WriteRegister == ID_Rt`: `lw`目标寄存器与当前指令的`Rs`或`Rt`相同

        - 阻塞`ID`和`IF`阶段的指令

            + `bubble`: 将`ID/EX`寄存器中`EX`,`MEM`和`WB`阶段需要的控制信号**清零**

            + `PC_IF_ID_Write`: 禁止`PC`和`IF/ID`寄存器接收新指令

- **转发数据**

    + 由于分支判断提前至`ID`阶段, 即在`ID`阶段需读取寄存器`Rs`和`Rt`的值, 而此时上一条指令(`EX`阶段的指令)以及上上条指令(`MEM`阶段的指令)还未写入寄存器, 存在数据冒险, 可通过转发解决

    + 转发条件

        - 当前指令为`beq`或`bne`: 需同时考虑`Rs`和`Rt`的冒险

            + `EX_RegWrite & ~MEM_RegWrite`: 上一条指令写回非零寄存器(以下均指非零寄存器), 上上条指令不写回

                - `EX_WriteRegister == ID_Rs || EX_WriteRegister == ID_Rt`: 转发数据`EX_ALUResult`

            + `~EX_RegWrite & MEM_RegWrite`: 上一条指令不写回, 上上条写回

                - `MEM_WriteRegister == ID_Rs || MEM_WriteRegister == ID_Rt`: 转发数据`MEM_ALUResult`

            + `EX_RegWrite & MEM_RegWrite`: 上两条指令都写回

                - 若上两条指令目标寄存器相同且与源寄存器之一相同, 则只转发上一条指令数据`EX_ALUResult`

                - 其余情况该转发啥转发啥, 不再赘述, 但**不转不是中国人**

        - 当前指令为`blez`, `bgtz`, `bgez`, `jr`: 与上述过程类似, 但只需判断`Rs`的冒险

### `EX` (Execute)

- 进行`ALU`计算

- 计算`lw`和`sw`的**访存地址**

- 控制信号

    + `ALUFun`: 选择`ALU`运算类型

    + `ALUSrc1`: 选择`ALU`第一个操作数

    + `ALUSrc2`: 选择`ALU`第二个操作数

    + `RegDst`: 选择目标寄存器

- **数据转发**

    + 产生控制信号

        - `Forward1`: 配合`ALUSrc1`选择`ALU`第一个操作数

        - `Forward2`: 配合`ALUSrc2`选择`ALU`第二个操作数

    + 转发条件**A**(同时满足以下三条则转发, *不转不是中国人*)

        1. `MEM_RegWrite == 1`: `MEM`级指令需写回寄存器

        2. `MEM_WriteRegister != 0`: `MEM`级指令写回的目标寄存器不是`$zero`

        3. `MEM_WriteRegister == EX_Rs || MEM_WriteRegister == EX_Rt`: `MEM`级指令写回的目标寄存器与`EX`级源寄存器之一相同

        - 转发数据: `MEM_RegWriteData`

    + 转发条件**B**(同时满足以下四条则转发)

        1. `WB_RegWrite == 1`: `WB`级指令需写回寄存器

        2. `WB_WriteRegister != 0`: `WB`级指令写回的目标寄存器不是`$zero`

        3. `WB_WriteRegister == EX_Rs || WB_WriteRegister == EX_Rt`: `WB`级指令写回的目标寄存器与`EX`级源寄存器之一相同

        4. 转发条件**A**不满足

        - 转发数据: `WB_RegWriteData`

### `MEM` (Memory)

- 访问存储器

- 控制信号

    + `MEMWrite`

    + `MEMRead`

### `WB` (Write Back)

- 将计算结果写会寄存器堆

- 控制信号
    
    + `MemToReg`: 数据来源(`MEM/WB`或存储器)

    + `RegWrite`


## 模块

### `cpu_pipeline.v`

```verilog
module cpu_pipeline (
    input clk,          // System Clock
    input rst_n,        // Asynchronous reset active low
    input uart_rx,      // UART receive data

    output uart_tx,     // UART transmit data
    output [7:0] led,   // Result
    output [6:0] digi1, // part I of operand1
    output [6:0] digi2, // part II of operand1
    output [6:0] digi3, // part I of operand2
    output [6:0] digi4  // part II of operand2
);
```

### `IF.v`

- `IF/ID`结构

    ```verilog
    // 64 bits
    // enable: PC_IF_ID_Write
    // reset: flush_IF_ID

    IF_ID[63:32] <= PC_plus4;
    IF_ID[31:0] <= instruction;
    ```

- 接口

    ```verilog
    module IF (
        input clk,      // Clock
        input rst_n,    // Asynchronous reset active low
        input PC_IF_ID_Write,          // Whether PC and IF_ID can be changed
        input [31:0] branch_target,
        input [31:0] jump_target,   
        input [31:0] jr_target,     
        input [2:0] select_PC_next, // {Z, J, Jr} to select next PC
        input [1:0] status,         // {interrupt, exception}
        
        output reg [63:0] IF_ID     // Register between IF and ID stage
    );
    ```

### `ID.v`

- `ID_EX`结构

    ```verilog
    // 191 bits
    // reset [158:143]: bubble

    ID_EX[31:0] <= ID_RtData;
    ID_EX[63:32] <= ID_RsData;
    ID_EX[68:64] <= ID_Rt;
    ID_EX[73:69] <= ID_Rs;
    ID_EX[78:74] <= ID_Rd;
    ID_EX[110:79] <= LuOut;
    ID_EX[142:111] <= shamt32;

    ID_EX[153:143] <= {ID_ALUCtl, ID_ALUSign, ID_ALUSrc1, ID_ALUSrc2, ID_RegDst};   // Control for EX

    ID_EX[155:154] <= {ID_MemRead, ID_MemWrite};    // for MEM

    ID_EX[158:156] <= {ID_MemtoReg, ID_RegWrite};   // for WB

    ID_EX[190:159] <= PC_plus4;     // For jal
    ```

- 接口

    ```verilog
    module ID (
        input clk,    // Clock
        input rst_n,  // Asynchronous reset active low

        input uart_signal,  // 1: there is new data from uart
        input uart_flag,    // 0: uart_register1, 1: uart_register2
        input [7:0] uart_rx_data,   // Data from uart

        input [31:0] instruction,   // Get instruction from IF_ID[31:0]
        input [31:0] PC_plus4,      // Get PC+4 from IF_ID[63:32]
        
        input WB_RegWrite,          // From WB_RegWrite
        input [4:0] WB_WriteRegister,   // From WB_WriteRegister
        input [31:0] WB_RegWriteData,   // From WB_RegWriteData

        // input EX_MemRead,   // Input for hazard unit to detect hazard
        input [4:0] EX_WriteRegister,   // Input for hazard unit to detect hazard

        // Output for uart
        output [7:0] uart_result_data,

        // Output for IF
        output Z,   // Whether goto branch target
        output J,   // Whether it's a Jump instruction
        output JR,  // Whether it's a Jump Register instruction
        output PC_IF_ID_Write,  // Enable for PC and IF_ID
        output [31:0] branch_target, 
        output [31:0] jump_target, 
        output [31:0] jr_target,
        output interrupt,
        output exception,

        output reg [190:0] ID_EX
    );
    ```

### `EX.v`

- `EX_MEM`结构

    ```verilog
    // 106 bits

    EX_MEM[31:0] <= EX_MemWriteData;
    EX_MEM[63:32] <= EX_ALUResult;
    EX_MEM[68:64] <= EX_WriteRegister;
    EX_MEM[70:69] <= {EX_MemWrite, EX_MemRead};     // For MEM
    EX_MEM[73:71] <= {EX_MemtoReg, EX_RegWrite};    // For WB
    EX_MEM[105:74] <= PC_plus4; // For jal
    ```

- 接口

    ```verilog
    module EX (
        input clk,    // Clock
        input rst_n,  // Asynchronous reset active low

        input [5:0] EX_ALUCtl,  // From ID_EX[153:148]; Select ALU operation type
        input EX_ALUSign,       // From ID_EX[147]
        input EX_ALUSrc1,       // From ID_EX[146]
        input EX_ALUSrc2,       // From ID_EX[145]
        input [1:0] EX_RegDst,  // From ID_EX[144:143]; 00: rt, 01: rd, 10: ra, 11: k0

        input [31:0] EX_Shamt32,    // From ID_EX[142:111]
        input [31:0] EX_LuOut,      // From ID_EX[110:79]

        input [4:0] EX_Rd,      // From ID_EX[78:74]
        input [4:0] EX_Rs,      // From ID_EX[73:69]
        input [4:0] EX_Rt,      // From ID_EX[68:64]

        input [31:0] EX_RsData, // From ID_EX[63:32]
        input [31:0] EX_RtData, // From ID_EX[31:0]

        // Input for forward
        input MEM_RegWrite,
        input [4:0] MEM_WriteRegister,
        input [31:0] MEM_RegWriteData,
        input WB_RegWrite,
        input [4:0] WB_WriteRegister, 
        input [31:0] WB_RegWriteData,

        // Pass from ID_EX to EX_MEM
        input EX_MemWrite,          // From ID_EX[154]
        input EX_MemRead,           // From ID_EX[155]
        input EX_RegWrite,          // From ID_EX[156]
        input [1:0] EX_MemtoReg,    // From ID_EX[158:157]
        input [31:0] PC_plus4,      // From ID_EX[190:159]

        // Output for ID
        // output EX_MemRead,          // From ID_EX[155]
        output [4:0] EX_WriteRegister,

        output [105:0] EX_MEM
    );
    ```

### `MEM.v`

- `MEM_WB`结构

    ```verilog
    // 104 bits

    MEM_WB[31:0] <= MEM_ALUResult;
    MEM_WB[63:32] <= MEM_ReadData;
    MEM_WB[68:64] <= MEM_WriteRegister;
    MEM_WB[71:69] <= {MEM_MemtoReg, MEM_RegWrite};
    MEM_WB[103:72] <= PC_plus4;
    ```

- 接口

    ```verilog
    module MEM (
        input clk,    // Clock
        input rst_n,  // Asynchronous reset active low
        
        input MEM_MemWrite,         // From EX_MEM[70]
        input MEM_MemRead,          // From EX_MEM[69]
        input [31:0] MEM_ALUResult, // From EX_MEM[63:32]
        input [31:0] MEM_WriteData, // From EX_MEM[31:0]

        // Pass from EX_MEM to MEM_WB
        input [31:0] PC_plus4,      // From EX_MEM[105:74]
        input [1:0] MEM_MemtoReg,   // From EX_MEM[73:72]
        input MEM_RegWrite,         // From EX_MEM[71]
        input [4:0] MEM_WriteRegister,  // From EX_MEM[68:64]

        output result_start,        // For uart, to receive result
        output irqout,
        output [7:0] led,
        output [11:0] digi,

        output [103:0] MEM_WB
    );
    ```

## 数据通路

```verilog
// cpu_pipeline.v

module cpu_pipeline (
    input clk,          // System Clock
    input rst_n,        // Asynchronous reset active low
    input uart_rx,      // UART receive data

    output uart_tx,     // UART transmit data
    output [7:0] led,   // Result
    output [6:0] digi1, // part I of operand1
    output [6:0] digi2, // part II of operand1
    output [6:0] digi3, // part I of operand2
    output [6:0] digi4  // part II of operand2
);

wire [63:0] IF_ID;
wire [190:0] ID_EX;
wire [105:0] EX_MEM;
wire [103:0] MEM_WB;

// IF
wire PC_IF_ID_Write; 
wire [31:0] branch_target;
wire [31:0] jump_target;
wire [31:0] jr_target;
wire Z, J, JR;  // To select next PC
wire interrupt, exception;  // Status of CPU

IF IF1(
    // Input
    .clk           (clk),
    .rst_n         (rst_n),
    .PC_IF_ID_Write(PC_IF_ID_Write),
    .branch_target (branch_target),
    .jump_target   (jump_target),
    .jr_target     (jr_target),
    .select_PC_next({Z, J, JR}),
    .status        ({interrupt, exception}),
    // Output
    .IF_ID         (IF_ID)
);

// ID
wire uart_signal;   // 1: there is new data from uart
wire uart_flag;     // Select uart write target (register)
wire uart_result_start;
wire [7:0] uart_rx_data;
wire [7:0] uart_result_data;

UART UART1(
    // Input
    .clk         (clk),
    .rst_n       (rst_n),
    .UART_RX     (uart_rx),
    .result_data (uart_result_data),
    .result_start(uart_result_start),
    // Output
    .rx_data     (uart_rx_data),
    .flag        (uart_flag),
    .signal      (uart_signal),
    .UART_TX     (uart_tx)
);

wire [4:0] EX_WriteRegister;

wire [1:0] WB_MemtoReg;
wire [31:0] WB_RegWriteData;

assign WB_MemtoReg = MEM_WB[71:70];
assign WB_RegWriteData = (WB_MemtoReg == 2'b00) ? MEM_WB[31:0] :    // MEM_ALUResult
                         (WB_MemtoReg == 2'b01) ? MEM_WB[63:32] :   // MEM_ReadData
                         (WB_MemtoReg == 2'b10) ? MEM_WB[103:72] :  // PC_plus4, jal
                         32'hffffffff;  // Unexpected behavior

wire irq;   // Interrupt request from MEM

ID ID1(
    // Input
    .clk             (clk),
    .rst_n           (rst_n),
    .uart_signal     (uart_signal),
    .uart_flag       (uart_flag),
    .uart_rx_data    (uart_rx_data),
    .irq             (irq),
    .instruction     (IF_ID[31:0]),
    .PC_plus4        (IF_ID[63:32]),
    .WB_WriteRegister(MEM_WB[68:64]),
    .WB_RegWrite     (MEM_WB[69]),
    .WB_RegWriteData (WB_RegWriteData),
    .EX_WriteRegister(EX_WriteRegister),
    // Output
    .uart_result_data(uart_result_data),
    .Z               (Z),
    .J               (J),
    .JR              (JR),
    .PC_IF_ID_Write  (PC_IF_ID_Write),
    .branch_target   (branch_target),
    .jump_target     (jump_target),
    .jr_target       (jr_target),
    .interrupt       (interrupt),
    .exception       (exception),
    .ID_EX           (ID_EX)
);

EX EX1(
    // Input
    .clk              (clk),
    .rst_n            (rst_n),
    .PC_plus4         (ID_EX[190:159]),
    .EX_MemtoReg      (ID_EX[158:157]),
    .EX_RegWrite      (ID_EX[156]),
    .EX_MemRead       (ID_EX[155]),
    .EX_MemWrite      (ID_EX[154]),
    .EX_ALUCtl        (ID_EX[153:148]),
    .EX_ALUSign       (ID_EX[147]),
    .EX_ALUSrc1       (ID_EX[146]),
    .EX_ALUSrc2       (ID_EX[145]),
    .EX_RegDst        (ID_EX[144:143]),
    .EX_Shamt32       (ID_EX[142:111]),
    .EX_LuOut         (ID_EX[110:79]),
    .EX_Rd            (ID_EX[78:74]),
    .EX_Rs            (ID_EX[73:69]),
    .EX_Rt            (ID_EX[68:64]),
    .EX_RsData        (ID_EX[63:32]),
    .EX_RtData        (ID_EX[31:0]),
    .MEM_RegWrite     (EX_MEM[71]),
    .MEM_WriteRegister(EX_MEM[68:64]),
    .MEM_RegWriteData (EX_MEM[63:32]),
    .WB_RegWrite      (MEM_WB[69]),
    .WB_WriteRegister (MEM_WB[68:64]),
    .WB_RegWriteData  (WB_RegWriteData),
    // Output
    .EX_WriteRegister (EX_WriteRegister),
    .EX_MEM           (EX_MEM)
);

wire [11:0] digi;

digitube_scan SCAN1(
    // Input
    .digi_in  (digi),
    // Output
    .digi_out1(digi1),
    .digi_out2(digi2),
    .digi_out3(digi3),
    .digi_out4(digi4)
);

MEM MEM1(
    // Input
    .clk              (clk),
    .rst_n            (rst_n),
    .PC_plus4         (EX_MEM[105:74]),
    .MEM_MemtoReg     (EX_MEM[73:72]),
    .MEM_RegWrite     (EX_MEM[71]),
    .MEM_MemWrite     (EX_MEM[70]),
    .MEM_MemRead      (EX_MEM[69]),
    .MEM_WriteRegister(EX_MEM[68:64]),
    .MEM_ALUResult    (EX_MEM[63:32]),
    .MEM_WriteData    (EX_MEM[31:0]),
    // Output
    .result_start     (uart_result_start),
    .led              (led),
    .digi             (digi),
    .irqout           (irq),
    .MEM_WB           (MEM_WB)
);

endmodule
```

### 调试日志

+ 提前分支判断存在数据冒险, 拟通过数据转发解决
