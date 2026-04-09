# Lab10C

> Shortest Path in 5*5 matrix
> 
- 題目
    - 設計一個類gps路線規劃電路 不斷走訪記錄長度 並回傳從起點至終點最短路徑
- 要求
    1. First matrix record point f(X,Y) info.
    2. Second matrix record distance info.
    3. Traveling route always start from points f(0,0) to f(4,4)
    4. Only go right and up direction
    5. Must record incremental path length when traced
    6. Input signals are synchronized at the clock rising edge.
    7. Active-high synchronous reset.
    8. When input retrieved, output must output within 50 cycles
- 步驟
    - 接收23個點 排除起/終點
    - DP shortest path
    - 計算最短路徑，同時記錄走訪的點&距離
    - 輸出時 依序輸出走訪的點
- 規格

| signal name | direction | bit width | description |
| --- | --- | --- | --- |
| CLK | I | 1 | CLK signal |
| RESET | I | 1 | Synchronous reset. |
| IN_VALID | I | 1 | Assert when IN_DATA is valid. |
| IN_DATA | I | 8 | Input distance data (unsigned number). |
| OUT_VALID | O | 1 | Assert when OUT_DATA is valid. |
| OUT_DATA_X | O | 4 | Output point x (unsigned number) |
| OUT_DATA_Y | O | 4 | Output point y (unsigned number) |
| OUT_DATA_SUM | O | 16 | Output distance sum (unsigned number) |



- 注意
    - code我寫成greedy不對 應該用DP (但TB還是過了)