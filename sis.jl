module SIS
using GameZero
struct Node
    pos::Vector{Int}
    link::Array{Node}
end

function link!(n1::Node, n2::Node)
    push!(n1.link, n2)
    push!(n2.link, n1)
end

function getdim(n::Node)
    return length(n.link)
end

struct BAmodel
    node_list::Array{Node}
end

function make_BAmodel(n_node::Int)::BAmodel
    if n_node < 2
        println("ERROR:n_node < 2")
    else
        n1 = Node([0,0], [])
        n2 = Node([0,0], [])
        link!(n1, n2)
        model = BAmodel([n1, n2])
        for i = 1:n_node-2
            newnode = Node([0,0], [])
            n1 = get_link(model, rand())
            link!(n1, newnode)
            n2 = get_link(model, rand())
            link!(n2, newnode)
        end
    end
    return model
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


end