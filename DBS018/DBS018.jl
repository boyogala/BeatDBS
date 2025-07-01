## DBS018.jl
cd("C:\\Users\\jwang7749\\Documents\\JuliaWorks\\BeatCODE\\DBS018")

DBS018_Dir = pwd()
## Packages
# Step 1: Create a new virtual environment
using Pkg
Pkg.activate("DBS018_Dir")

# Step 2: Install packages in the virtual environment
Pkg.add("JuMP")
Pkg.add("AmplNLWriter")
Pkg.add("Images")

# Step 3: Activate the virtual environment
# 优化建模
using JuMP,AmplNLWriter
# 线性代数
using LinearAlgebra
# 图像处理
using Images

# 设置处理图像类型
imgT = Float64

# 读取一个彩色图像
img00 = load("grid00.png")
img01 = load("underwater.jpg")

# 转化为灰度图像
img00_gray = Gray.(img00)
img01_gray = Gray.(img01)

# 将图像的颜色通道分离为单独的数组
channelview(img00_gray)
channelview(img01_gray)

# 把灰色图像 ---> 数值矩阵[0,1]
mat00 = Matrix{imgT}(img00_gray)
mat01 = Matrix{imgT}(img00_gray)

