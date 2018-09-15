mutable struct GosperIterator
    n::Int64
    k::Int64
    GosperState::Tuple{Int64, Int64}
end

"""
    gosper(n, k)
Returns iterator over numbers whose binary representation correspond to the
indicator vector of a subset of {1,...,n} of size k.
Example:
   collect(gosper(3,2)) == [3, 5, 6]
"""
function gosper(n::Int, k::Int)
    @assert 0 < k <= n <= 62
    return GosperIterator(n, k, (2^k - 1, 2^n -1))
end

const GosperState = Tuple{Int64, Int64}

Base.eltype(it::GosperIterator) = Int64
Base.length(it::GosperIterator) = binomial(it.n, it.k)


function start(it::GosperIterator)
    (2^it.k - 1, 2^it.n -1)
end

function next(it::GosperIterator, state::Int64)
    # Gosper's hack: Finds the next smallest number with exactly k bits
    # set to 1 in its binary representation.

    o = it.GosperState[1]
    u = it.GosperState[1] & -it.GosperState[1]
    v = u + it.GosperState[1]
    # ⊻: bitwise xor
    y = v + (div(v ⊻ it.GosperState[1], u) >> 2)

    it.GosperState = (y,it.GosperState[2])

    
    if it.GosperState[1] > it.GosperState[2]
        return nothing
    end
    
    return it.GosperState[1],y
end

Base.iterate(it::GosperIterator) = start(it)
Base.iterate(it::GosperIterator, state::Int64) = next(it,state)
