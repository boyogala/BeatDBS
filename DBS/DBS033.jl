# 导入txt数据处理包
using DelimitedFiles
# 可视化
using Plots
# 优化建模包和求解器
using JuMP,AmplNLWriter
# 读取txt格式的数据
p2l = readdlm("point2line.txt",
',',#数据分隔符,
Float64 #数据格式Float64
)
# 保存为横纵坐标的数据：xd和yd
xd = p2l[:,1]
yd = p2l[:,2]
#样本数量
M = length(xd)

# 可视化数据
scatter(xd,yd,
xlabel = "x",
ylabel = "y",
legend =false)

# 第一种距离：绿色的线段PN
# 建立模型
ls = Model(()->AmplNLWriter.Optimizer("C:\\solvers.amplc\\conopt436\\conopt.exe",["outlev=4"]))

# 增加变量
@variable(ls,-10 <= ls_a <= 10)
@variable(ls,-10 <= ls_b <= 10)

# 增加目标函数
@objective(ls,Min,sum((ls_a * xd[i] + ls_b - yd[i])^2 for i in 1:M))

# 求解模型
optimize!(ls)

# 输出结果
println("第一种距离：绿色的线段PN，其斜率为ls_a = :",value(ls_a))
println("第一种距离：绿色的线段PN，其截距为ls_b = :",value(ls_b))
objective_value(ls)
# 可视化直线
ls_y = value(ls_a) .* xd .+ value(ls_b)
plot!(xd,ls_y,color=:red)

# 第二种距离：蓝色的线段PQ
# 建立模型
tls = Model(()->AmplNLWriter.Optimizer("C:\\solvers.amplc\\conopt436\\conopt.exe",["outlev=4"]))

# 增加变量
@variable(tls,-10 <= tls_a <= 10)
@variable(tls,-10 <= tls_b <= 10)

# 增加目标函数
@objective(tls,Min,sum((tls_a * xd[i] + tls_b - yd[i])^2/(1+tls_a^2) for i in 1:M))

# 求解模型
optimize!(tls)

# 输出结果
println("第二种距离：蓝色的线段PQ，其斜率为tls_a = :",value(tls_a))
println("第二种距离：蓝色的线段PQ，其截距为tls_b = :",value(tls_b))

# 可视化直线
tls_y = value(tls_a) .* xd .+ value(tls_b)
plot!(xd,tls_y,color=:blue)

objective_value(tls)

# 第三种距离：黑色的线段PM
# 建立模型
hls = Model(()->AmplNLWriter.Optimizer("C:\\solvers.amplc\\conopt436\\conopt.exe",["outlev=4"]))

# 增加变量
@variable(hls,-10 <= hls_a <= 10)
@variable(hls,-10 <= hls_b <= 10)

# 增加目标函数
@objective(hls,Min,sum((hls_a * xd[i] + hls_b - yd[i])^2/(1e-6+hls_a^2) for i in 1:M))

# 求解模型
optimize!(hls)

# 输出结果
println("第三种距离：黑色的线段PM，其斜率为hls_a = :",value(hls_a))
println("第三种距离：黑色的线段PM，其截距为hls_b = :",value(hls_b))

# 可视化直线
hls_y = value(ls_a) .* xd .+ value(hls_b)
plot!(xd,hls_y,color=:black)

objective_value(hls)