# Fundmentals   
## Creating Tensors   
 --- 
**在PyTorch上，我們會透過 torch.tensor 這個 class 來建構張量。對於一個Tensor 我們幾種型態可以去建構，Example : **   
**Scalar (0D Tensor)、Vector (1D Tensor)、Matrix  (2D Tensor)、Tensor (3D Tensor)**   
**而我們也可以透過一些指令去取得該Tensor的一些資訊，Example : **   
**.ndim 可以取得張量的維度，.shape 可以取得該張量在每個維度上的大小。**   
```
import torch
scalar = torch.tensor(7) # Create a scalar tensor

print(scalar)
print(scalar.ndim)
print(scalar.shape)

vector = torch.tensor([7,7]) # Create a vector tensor

print(vector)
print(vector.ndim)
print(vector.shape)

Matrix = torch.tensor([[7,8],[9,10]]) # Create a Matrix tensor

print(Matrix)
print(Matrix.ndim)
print(Matrix.shape)

Tensor = torch.tensor([[[1,2,3],
						[3,6,9],
						[2,4,5]]])

print(Tensor)
print(Tensor.ndim)
print(Tensor.shape)
```
```
tensor(7)
0
torch.Size([])

tensor([7, 7])
1
torch.Size([2])

tensor([[ 7,  8],
        [ 9, 10]])
2
torch.Size([2, 2])

tensor([[[1, 2, 3],
         [3, 6, 9],
         [2, 4, 5]]])
3
torch.Size([1, 3, 3])

```
![image.png](files\image.png)    

   
   
**通常來說，Scalar and Vector 我們會以小寫表示，例如 : y、a，但是 Matrix and Tensor 我們則會用大寫表示，例如 : X、W 。**   
**而在PyTorch上Tensor和Matrix常常被混用，因為我們處理的是 torch.tensor，因此無論他是Scalar、Vector or Matrix 都被稱為 Tensor (張量) 。**
   
![image.png](files\image_8.png)    
   
## Random Tensor   
 --- 
**利用 torch.rand 可以建立一個 Value 由 0 ~ 1 的隨機張量，其大小由使用者自行設定。**   
**利用 .dtype 可以得到 tensor 的 Data Type 。**   
```
import torch
# Create a random tensor of size (3,4)
random_tensor = torch.rand(size=(3,4))

print(random_tensor)
print(random_tensor.dtype)
print(random_tensor.shape)

random_image_size_tensor = torch.rand(size=(224,224,3))
print(random_image_size_tensor)
print(random_image_size_tensor.dtype)
print(random_image_size_tensor.shape)


```
```
tensor([[0.0297, 0.6634, 0.1681, 0.3665],
        [0.1887, 0.1646, 0.1023, 0.6460],
        [0.4443, 0.0256, 0.2212, 0.0679]])
torch.float32
torch.Size([3, 4])

#....是因為Terminal省略掉中間部分沒有印出
tensor([[[0.7704, 0.3502, 0.4000],
         [0.4471, 0.0188, 0.7466],
         [0.5604, 0.8418, 0.4131],
         ...,
		[[0.5486, 0.1556, 0.8636],
         [0.0870, 0.3702, 0.3266],
         [0.7028, 0.5136, 0.7279],
         ...,
         [0.8313, 0.0916, 0.4064],
         [0.7182, 0.6606, 0.0126],
         [0.0446, 0.0815, 0.1365]]])
torch.float32
torch.Size([224, 224, 3])			

```
   
## Zeros and Ones    
 --- 
```
import torch
# Create a tensor of all zeros
zeros = torch.zeros(size=(3,4))
print(zeros,zeros.dtype)

# Create a tensor of all ones
ones = torch.ones(size=(3,4),dtype=torch.int)
print(ones,ones.dtype)

```
```
tensor([[0., 0., 0., 0.],
        [0., 0., 0., 0.],
        [0., 0., 0., 0.]]) torch.float32
tensor([[1, 1, 1, 1],
        [1, 1, 1, 1],
        [1, 1, 1, 1]], dtype=torch.int32) torch.int32

```
   
   
## Creating a range and tensors    
 --- 
**在 PyTorch 中，我們不會使用 Python 中 range ( )，而是使用arrange ( ) 來操作。**   
**start  =  start of range .**   
**end  =  end of range .**   
**step  =  how many steps in between each value .**   
```
import torch

zero_to_ten = torch.arange(start=0, end=10, step=1) 
print(zero_to_ten)

# Can also creat a tensor of zero similar to another tensor
ten_zeros = torch.zeros_like(input=zero_to_ten)
print(ten_zeros)

# Can Copy
zero_to_ten_copy = zero_to_ten.clone()
print(zero_to_ten_copy
```
```
tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
tensor([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
```
   
   
## Tensor Data Type    
 --- 
**PyTorch 詳細的資料型態可以到下面的網址去搜索 : **   
[torch.Tensor — PyTorch 2.6 documentation](https://pytorch.org/docs/stable/tensors.html#data-types)    
**以下是 PyTorch 裡面常見的資料型態 : **   
![image.png](files\image_s.png)    
   
   
###    
###    
###    
###    
###    
### ***Complex Data Type : ***   
**以 torch.complex64為例子**   
**其中 32 個位元作為實部，另外32位元作為虛部**   
```
import torch
float_32_tensor = torch.tensor([3.0,6.0,9.0],dtype=None,device=None,requires_grad=False)
print(float_32_tensor.shape,float_32_tensor.dtype,float_32_tensor.device)

float_16_tensor = torch.tensor([3.0,6.0,9.0],dtype=torch.float16)
print(float_16_tensor.dtype)
```
```
torch.Size([3]) 
torch.float32 cpu
torch.float16
```
   
   
## Matrix Multiplication    
 --- 
[Matrix Multiplication](http://matrixmultiplication.xyz/)    
*PyTorch implements Matrix Multiplication functionality in the torch.matmul( )*   
*And in PyTorch we not only can use @ to replace torch.matmul , but also use torch.mm( )*   
   
**Matrix Multiplication Rules : **   
1. The inner dimensions must match.     
    (3,2) @ (3,2) won't work.   
    (2,3) @ (3,2) will work.   
2. The resulting matrix has the shape of the outer dimensions.   
    (2,3) @ (3,2)  →  (2,2) .   
    (3,4) @ (4,2)  →  (3,2) .   
   
###    
### Element-Wise Multiplication vs Matrix Multiplication :    
![image.png](files\image_m.png)    
```
import torch
tensor = torch.tensor([1,2,3]) 
print(tensor.shape)

#Element-wise Multiplication
print(tensor*tensor)

# Matrix Multiplication -> matmul
print(torch.matmul(tensor,tensor))
print(tensor@tensor) #use @ to replace matuml

```
```
torch.Size([3])
tensor([1, 4, 9])
tensor(14)
tensor(14)







```
**A Matrix Multiplication like this is also referred to as the dot product of two matrices.**   
   
### Create a Fully Connected Layer :    
In PyTorch , The **torch.nn.Linear ( )** , *Call feed-forward layer or fully connected layer *.     
Implement a matrix multiplication between an input x and a weights matrix A .   
** **   

$$
 y = x{W^T} + b 
$$
   
```
import torch

tensor_A = torch.tensor([[1,2],
                        [3,4],
                        [5,6]],dtype=torch.float32,requires_grad=False)

torch.manual_seed(42) # Set Random seed

# This uses matrix multiplication W is 6x2 (According the random seed)
linear = torch.nn.Linear(in_features=2,out_features=6) 

# Don't require gradient trace
linear.weight.requires_grad_(False)
linear.bias.requires_grad_(False)

x = tensor_A # X is 3x2
output = linear(x) # Can get 3x6 tensor
print(f"Bias Parameter : {linear.bias}")
print(f"Bias Value : {linear.bias.data}")
print(f"\nInput shape : {x.shape}\n")
print(f"Output : \n{output}\n\nOutput shape : {output.shape}")

```
```
Bias Parameter : Parameter containing:
tensor([ 0.5224,  0.0958,  0.3410, -0.0998,  0.5451,  0.1045])
Bias Value : tensor([ 0.5224,  0.0958,  0.3410, -0.0998,  0.5451,  0.1045])

Input shape : torch.Size([3, 2])

Output :
tensor([[2.2368, 1.2292, 0.4714, 0.3864, 0.1309, 0.9838],
        [4.4919, 2.1970, 0.4469, 0.5285, 0.3401, 2.4777],
        [6.7469, 3.1648, 0.4224, 0.6705, 0.5493, 3.9716]])

Output shape : torch.Size([3, 6])
```
   
