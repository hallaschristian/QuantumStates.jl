struct ProductState{T1<:BasisState, T2<:BasisState} <: BasisState
    basis_state1::T1
    basis_state2::T2
end
export ProductState

overlap(state::ProductState{T1,T2}, state′::ProductState{T3,T4}) where {T1,T2,T3,T4} = 
    overlap(state.basis_state1, state′.basis_state1) * overlap(state.basis_state2, state′.basis_state2)

function print_basis_state(product_state::ProductState)
    str = print_basis_state(product_state.basis_state1)
    str *= print_basis_state(product_state.basis_state2)
    return str
end
export print_basis_state

function make_product_basis(basis1, basis2)
    basis1_type = typeof(basis1).parameters[1]
    basis2_type = typeof(basis2).parameters[1]
    product_basis = ProductState{basis1_type, basis2_type}[]
    for b_state ∈ basis1
        for b_state′ ∈ basis2
            push!(product_basis, ProductState(b_state, b_state′))
        end
    end
    return product_basis
end
export make_product_basis

function Identity(state::ProductState, state′::ProductState)
    return state == state′
end
export Identity

function subspace(states::Vector{State{ProductState{T1,T2}}}, QN_bounds1, QN_bounds2, threshold=0.01) where {T1<:BasisState,T2<:BasisState}
    subspace = State{ProductState{T1,T2}}[]
    subspace_idxs = Int64[]
    add_to_subspace = ones(Bool, length(states))

    QNs = keys(QN_bounds1)
    for QN ∈ QNs
        for (i, state) ∈ enumerate(states)
            for (j, coeff) ∈ enumerate(state.coeffs)
                if getfield(state.basis[j].basis_state1, QN) ∉ QN_bounds1[QN]
                    if norm(coeff)^2 > threshold
                        add_to_subspace[i] = false
                    end
                end
            end
        end
    end

    QNs = keys(QN_bounds2)
    for QN ∈ QNs
        for (i, state) ∈ enumerate(states)
            for (j, coeff) ∈ enumerate(state.coeffs)
                if getfield(state.basis[j].basis_state2, QN) ∉ QN_bounds2[QN]
                    if norm(coeff)^2 > threshold
                        add_to_subspace[i] = false
                    end
                end
            end
        end
    end

    for i ∈ eachindex(states)
        if add_to_subspace[i]
            push!(subspace, states[i])
            push!(subspace_idxs, i)
        end
    end
    return (subspace_idxs, subspace)
end
export subspace