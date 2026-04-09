# Lab11B

> Design a Square Root Circuit
> 
- 題目
    - 設計一個平方根電路
- 要求
    1. Input is a 16-bit unsigned integer 
    2. precision for output (OUT) is 12-bits, 8-bit  integer part and 4-bit fraction.
    3. Synchronized at clock rising edge. 
    4. Active high asynchronous reset.
    5. Must be ready within 20 cycles after each input. 
- 步驟
    - 接收input
    - 從最高位開始，逐一測試 `(root | bitmask)^2` 是否≤目標值
    - 其中小數4bit 所以要算到5bit 四捨五入 `root[0]` 然後取`root[12:1]`
- 規格

| signal name | direction | bit width | description |
| --- | --- | --- | --- |
| CLK | I | 1 | Clock signal (synchronous at rising edge).  |
| RST | I | 1 | Synchronous reset signal (active high).  |
| IN_VALID | I | 1 | Assert when IN is valid. |
| IN | I | 16 | Input unsigned integer number |
| OUT_VALID | O | 1 | Assert when OUT is valid. |
| OUT | O | 12 | Output number |
