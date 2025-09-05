# 打编程系列之 019


# versioninfo()
# 导入建模语言
using JuMP

# 数据结构
using DataFrames
using LinearAlgebra

# 导入（混合整数）线性规划求解： HiGHS GLPK Cbc
using HiGHS

# 商业求解器
#using BARON,CPLEX
 
DBS019 = Model(HiGHS.Optimizer)
 
     # 给出数据
    Week     =   7
    Classe   =   3
	N = 16
 
    # 每周天每班次所需要的员工人数
    wcD     =   [3 6 2 3 4 7 5;7 4 3 5 3 5 2;2 3 4 2 3 2 3]

    # 增加 决策变量x[k,j,i]
    @variable(DBS019, x[1:Classe, 1:Week, 1:N], Bin)

    ## 增加约束条件
    # 每人每天最多一个班次
    # @constraint(DBS019, 每人每天最多一个班次[j = 1:Week, i = 1:N], sum( x[k,j,i] for k in 1:3) <= 1 )
    @constraint(DBS019, Cond1[j = 1:Week, i = 1:N], sum( x[k,j,i] for k in 1:3) <= 1 )

    # 不能连续两个班次值班
    @constraint(DBS019, Cond2[j = 1:Week-1, i = 1:N],   x[1,j+1,i] + x[Classe,j,i]  <= 1 )
    @constraint(DBS019, Cond2B[i = 1:N], x[Classe,Week,i] + x[1,1,i] <= 1 )

    # 每人工作不超过5天
    @constraint(DBS019, Cond3[i = 1:N], sum( x[k,j,i] for k in 1:Classe, j in 1:Week )  <= 5 )  

    # 每个班次的员工数量要满足需求量 
    @constraint(DBS019, Cond4[k = 1:Classe,j = 1:Week], sum( x[k,j,i] for i in 1:N ) >= wcD[k,j] )

    # 定义目标函数
    # 最小化被安排的次数
    # @objective(DBS019, Min, sum( x[k,j,i] for k in 1:Classe, j in 1:Week, i in 1:N ))
    # 最小化夜天排班
    # @objective(DBS019,Min, sum(  x[2,j,i] + x[3,j,i] for j in 1:Week, i in 1:N ) )
    # 最大化白天排班
    # @objective(DBS019, Max, sum( x[1,j,i] for j in 1:Week, i in 1:N ) )
    # 为了使得夜班排版次数少和白班排班次数多，技巧: 所有夜班的排班次数 - 所有白班排班次数，这个目标函数竟然可以使得所有员工的排版次数是一样的！！！
     @objective(DBS019,Min,  sum( x[2,j,i] + x[3,j,i] for j in 1:Week, i in 1:N ) - sum( x[1,j,i] for j in 1:Week, i in 1:N ) )
    
    # 打印出模型
    # println("排班问题")
    # print(DBS019)

    # 把模型输出位 mps 格式的
    # write_to_file(DBS019, "SPModel.mps")
    # write_to_file(DBS019, "SPModel.lp")
	# write_to_file(DBS019, "DBS019.nl")
	
    # 求解模型
    @timev  optimize!(DBS019)

    # 打印出求解结果
    println("\n 显示模型是否可被有效求解:  ")
    @show termination_status(DBS019)

    # 打印出每个员工的班次时间
    res_X   =   JuMP.value.(x);
    
    # 输出表格
    banci = ["早班","中班","晚班"];
    # weeks = ["周一","周二","周三","周四","周五","周六","周日"]
    	    for i = 1:N
	        # 中间变量
	        Xi = res_X[:,:,i]
	        # 员工的被安排工作量
	        IDworks     =  round( sum(sum(Xi)) )   
	        println("编号ID : WJS0000$i 的员工被安排了 $IDworks 次的值班时间表: ")
	        # 输出表格
	        Dfi = DataFrame(; 班次 = banci, 周一 = Xi[:,1],周二 = Xi[:,2],周三 = Xi[:,3],周四 = Xi[:,4],周五 = Xi[:,5],周六 = Xi[:,6],周日 = Xi[:,7])
	        println(Dfi)
	        println("\n")
	    end

	    # 打印出目标函数
	    println(" 目标函数值 = ： ")   
	    @show objective_value(DBS019)

	    # 原问题是否可行
	    println(" \n 判断优化问题是否可被有效求解 :  ")   
	    @show  primal_status(DBS019)
