# cpu-pipeline
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

    + 冒险条件成立时产生`stall`信号, 清空`ID/EX`, 插入一个流水线气泡

        - 冒险条件(同时满足以下两条则冒险成立)

            1. `EX_MemRead == 1`: 上一条指令(`EX`阶段指令)是`lw`

            2. `EX_WriteRegister == ID_Rs || EX_WriteRegister == ID_Rt`: `lw`目标寄存器与当前指令的`Rs`或`Rt`相同

        - 阻塞`ID`和`IF`阶段的指令

            + `Stall`: 将`ID/EX`寄存器中`EX`,`MEM`和`WB`阶段需要的控制信号**清零**

            + `PC_IF_Write`: 禁止`PC`和`IF/ID`寄存器接收新指令

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

    ```verilog
    module IF (
        input clk,      // Clock
        input rst_n,    // Asynchronous reset active low
        input PC_IF_ID_Write,          // Whether PC and IF_ID can be changed
        input [31:0] branch_target,
        input [31:0] jump_target,   
        input [31:0] jr_target,     
        input [2:0] select_PC_next, // {Z, J, Jr} to select next PC
        input [1:0] status,         // 00: normal, 01: Reset, 10: Interrupt, 11: Exception
        
        output reg [63:0] IF_ID     // Register between IF and ID stage
    );
    ```