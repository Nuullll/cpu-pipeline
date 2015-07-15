# cpu-pipeline
数字逻辑与处理器基础夏季学期 - **CPU流水线**

## 流水线结构

### `IF` (Instruction Fetch)

- 从`InstructionMemory`(`ROM`)中抓取指令

- 在下个时钟沿将**指令**和**当前**`PC`**写入`IF/ID`寄存器

### `ID` (Instruction Decode)

- 从`IF/ID`中获取指令进行译码

- 利用`Control`模块产生控制信号

- 进行**冒险检测**

    + 需求

        - 上一条指令的`MEMRead`

    + 冒险条件成立时产生`stall`信号, 清空`ID/EX`, 插入一个流水线气泡

### `EX` (Execute)

- 进行`ALU`计算

- 计算`lw`和`sw`的**访存地址**

- 控制信号

    + `ALUFun`: 选择`ALU`运算类型
    + `ALUSrc1`: 选择`ALU`第一个操作数
    + `ALUSrc2`: 选择`ALU`第二个操作数
    + `RegDst`: 选择目标寄存器

- **数据转发**

    + 产生控制信号`ForwardA`和`ForwardB`

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

