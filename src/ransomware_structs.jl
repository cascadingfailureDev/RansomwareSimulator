abstract type AbstractActionType end
struct Infect <: AbstractActionType end
struct Encrypting <: AbstractActionType end
struct Encrypted <: AbstractActionType end

struct ActionType{T<:AbstractActionType}
    type::String
end

INFECT = ActionType{Infect}("Infect")
ENCRYPTING = ActionType{Encrypting}("Encrypting")
ENCRYPTED = ActionType{Encrypted}("Encrypted")

# define simulation parameters
Base.@kwdef struct Parameters
    random_seed::Int
    rng::Random.MersenneTwister
    attack_parallelism::Int
    encrypt_gbs⁻¹::Int
    forensics::Int
    restore_time::Int
    post_ante::Vector{Dict{Any}}
end

# define possible changes in server state
Base.@kwdef mutable struct InfectionStatus
    infected::Bool
    encrypted::Bool
    encrypting::Bool
    encryption_start::Union{Int, Nothing}
end

# create an abstract server type to allow for circular reference between
# target and server
abstract type AbstractServer end

# define target as server to be infected and time remianing before infection
# of that server occurs
Base.@kwdef mutable struct Target
    target::AbstractServer
    tᵣ::Int
end

# define a server
Base.@kwdef struct Server <: AbstractServer
    system_id::String
    disk_size::Int
    susceptible::Bool
    t_to_encrypt::Int
    status::InfectionStatus
    targets::Vector{Target}
end

# define action in terms of action type, the server that began the action, the
# server that will be acted upon and the step at which the action occured
Base.@kwdef struct Action
    action::ActionType
    initiator::Union{Server, Nothing}
    subject::Union{Server, Nothing}
    step::Int
end

Base.@kwdef struct EncryptedGB
    step::Int
    encrypted::Float64
end

# define current state of the system in terms of the current state of all
# servers, the current step, and all actions that have occured since step 0
Base.@kwdef mutable struct State
    state::Vector{Server} = []
    step::Int = 0
    actions::Vector{Action} = []
    infected_servers::Int = 0
    encrypting_servers::Int = 0
    encrypted_servers::Int = 0
    encrpyted_gb::Vector{EncryptedGB} = []
    susceptible:: Int = 0
end
