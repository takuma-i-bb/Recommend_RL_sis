using GameZero
using LinearAlgebra

mutable struct Node
    pos::Vector{Float64}
    vel::Vector{Float64}
    link::Array{Node}
end

function link!(n1::Node, n2::Node)
    push!(n1.link, n2)
    push!(n2.link, n1)
end

function getdim(n::Node)
    return length(n.link)
end

function getrand()
    return [640 , 480] .* rand(2)
end

struct BAmodel
    node_list::Array{Node}
end

function make_BAmodel(n_node::Int)::BAmodel
    if n_node < 2
        println("ERROR:n_node < 2")
    else
        n1 = Node(getrand(), [0.0, 0.0],[])
        n2 = Node(getrand(), [0.0, 0.0],[])
        link!(n1, n2)
        model = BAmodel([n1, n2])
        for i = 1:n_node-2
            newnode = Node(getrand(), [0.0, 0.0],[])
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
                    f -= 0.1 .* (norm(n.pos - n2.pos) - 20) .* (n.pos - n2.pos) ./ norm(n.pos - n2.pos)
                    
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

function el_draw(m::BAmodel)
    
    for n in m.node_list
        el_draw(n, colorant"orange")
    end
end

function el_draw(n::Node, c)
    
    draw(Circle(floor.(n.pos)[1], floor.(n.pos)[2], getdim(n)*2), c, fill=true)
    for n2 in n.link
        draw(Line(floor.(n.pos)[1], floor.(n.pos)[2], floor.(n2.pos)[1], floor.(n2.pos)[2]))
    end
end

WIDTH = 640
HEIGHT = 480
#BACKGROUND = colorant"black"


model = make_BAmodel(20)
function draw()
    el_draw(model)
end

function update()
    
end