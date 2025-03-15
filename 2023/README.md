Test Pattern Record
-
PATTERN img5.pattern -> cover =  23, optimum =  23  C1(3,10),C2(10,11)  
PATTERN img4.pattern -> cover =  29, optimum =  30  C1(11,9),C2(5,5)  
PATTERN img6.pattern -> cover =  30, optimum =  30  C1(13,2),C2(8,9)   
PATTERN img3.pattern -> cover =  28, optimum =  29  C1(4,7),C2(11,8)  
PATTERN img1.pattern -> cover =  30, optimum =  30  C1(11,12),C2(4,10)  
PATTERN img2.pattern -> cover =  28, optimum =  28  C1(5,11),C2(11,6)  

### Cover total = 168/170  
單一測試樣本Cycle數 : 25268個cycle左右

New_LEASER.v  
-
改用25宮格做迭代修正  
單一測試樣本Cycle數 : 32000個cycle左右  

### Cover Total = 169/170  

### 問題 : 迭代演算法設計Bad  
  
  
Pattern 3  
進入迭代修正前 : (7,7)、(11、8) -> Cover : 22/29   
進入迭代修正後 :   
第一次 : (5,8)、(12,8) -> Cover : 28/29  
第二次 : (5,8)、(11,8) -> Cover : 28/29  
第三次 : (4,7)、(10,9) -> Cover : 28/29  
第四次 : (4,7)、(11,8) -> Cover : 28/29  
第五次 : (5,8)、(12,8) -> Cover : 28/29 繞回第一次迭代  
