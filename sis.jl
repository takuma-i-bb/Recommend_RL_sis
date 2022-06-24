using GameZero
using LinearAlgebra

mutable struct Node
    pos::Vector{Float64}
    vel::Vector{Float64}
    link::Array{Node}
    favorite::Float64
    category::Float64
end

function link!(n1::Node, n2::Node)
    push!(n1.link, n2)
    push!(n2.link, n1)
end

function getdim(n::Node)
    return length(n.link)
end

function getcolor(n::Node)
    cmap = [colorant"blue", colorant"green", colorant"red", colorant"orange", colorant"yellow"]
    return cmap[getintcategory(n)]
end

function getintcategory(n::Node)
    return mod(floor(Int, n.category + 0.5), 1:5)
end

function isconcern(n::Node, n2::Node)
    return (abs(getintcategory(n) - getintcategory(n2)) == 4 || (-1 <= getintcategory(n) - getintcategory(n2) <= 1)) ? true : false
end

function isconcern(n::Node, c::Int)
    return (abs(getintcategory(n) - c) == 4 || (-1 <= getintcategory(n) - c <= 1)) ? true : false
end

function getrand()
    return [640 , 480] .* rand(2)
end

function updatecategory!(n::Node)
    for n2 in n.link
        change = 0
        if isconcern(n, n2)
            change += (getintcategory(n2) - getintcategory(n)) * 0.05 * getdim(n2) / getdim(n)
            if getintcategory(n2) - getintcategory(n) == 0
                change += (getintcategory(n) -  n.category) * 0.01 * getdim(n2) / getdim(n)
            end
        end
        n.category += max(min(change, 0.5), -0.5)
        if n.category >= 5
            n.category -= 5
        end
    end
end

function updatecategory!(n::Node, c::Int)
    if isconcern(n, c)
        change += (c - getintcategory(n) * 0.1)
        if c == getintcategory(n)
            change += (c - n.category) * 0.02
        end
    end
    n.category += max(min(change, 0.5), -0.5)
    if n.category >= 5
        n.category -= 5
    end
end

function check_use(n::Node)
    return (100 * rand() < n.favorite) ? true : false
end

function recommend!(n::Node, c::Int)
    updatecategory!(n, c)
    if n.category == c
        n.favorite = min(n.category+5, 100)
    else if isconcern(n, c)
        n.favorite = min(n.category+3, 100)
    else
        n.favorite = max(n.category-5, 0)
    end
end

struct BAmodel
    node_list::Array{Node}
end

function make_BAmodel(n_node::Int)::BAmodel
    if n_node < 2
        println("ERROR:n_node < 2")
    else
        n1 = Node(getrand(), [0.0, 0.0],[], 100, 5 * rand())
        n2 = Node(getrand(), [0.0, 0.0],[],100, 5 * rand())
        link!(n1, n2)
        model = BAmodel([n1, n2])
        for i = 1:n_node-2
            newnode = Node(getrand(), [0.0, 0.0],[],100, 5 * rand())
            n1 = get_link(model, rand())
            link!(n1, newnode)
            n2 = get_link(model, rand())
            link!(n2, newnode)
            push!(model.node_list, newnode)
        end
        
        energy = 10

        while energy > 1e-3
            energy = 0
            for n in model.node_list
                f = [0, 0]
                for n2 in model.node_list
                    if(n.pos != n2.pos)
                        f += 280 .*(n.pos - n2.pos) ./ norm(n.pos - n2.pos)^2
                    end
                end
                for n2 in n.link
                    f -= 0.15 .* (norm(n.pos - n2.pos) - 20) .* (n.pos - n2.pos) ./ norm(n.pos - n2.pos)
                    
                end
                n.vel = (n.vel + (0.01 / getdim(n)) .* f) .* 0.9
                n.pos = n.pos + 0.01 .* f
                energy += getdim(n) *n.vel' * n.vel 
            end
            # println(energy)
        end

        g = [0,0]
        for n in model.node_list
            g += n.pos
        end
        g = g ./ length(model.node_list)
        mv = [320, 240] - g
        for n in model.node_list
            n.pos += mv
        end

        return model
    end
    
end

function totaldim(m::BAmodel)
    res = 0
    for n in m.node_list
        res += getdim(n)
    end
    return res
end

function get_link(m::BAmodel, rand::AbstractFloat)::Node
    tdim = totaldim(m)
    sum = 0
    for n in m.node_list
        sum += getdim(n) / tdim
        if(rand < sum)
            return n
        end
    end
end

function updatecategory!(m::BAmodel)
    for n in m.node_list
        updatecategory!(n)
    end
end

function recommend(m::BAmodel)
    for n in m.node_list
        if check_use(n)
            c = use_system(n)
            recommend!(n, c)
        end
    end
end

function el_draw(m::BAmodel)
    
    for n in m.node_list
        el_draw(n)
    end
end

function el_draw(n::Node)
    
    draw(Circle(floor.(n.pos)[1], floor.(n.pos)[2], getdim(n)*2), getcolor(n), fill=true)
    for n2 in n.link
        draw(Line(floor.(n.pos)[1], floor.(n.pos)[2], floor.(n2.pos)[1], floor.(n2.pos)[2]))
    end
end

function use_system(n::Node)
    
end

WIDTH = 640
HEIGHT = 480
#BACKGROUND = colorant"black"


model = make_BAmodel(20)
function draw()
    el_draw(model)
end

flamerate = 0
function update()
    global flamerate += 1
    if flamerate % 60 == 0
        updatecategory!(model)
        # println(map(n -> n.category, model.node_list))
    end
end