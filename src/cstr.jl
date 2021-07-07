using Plots,DifferentialEquations

########################### CSTR MODEL #############################
function cstr(du,u,p,t)

    Ca,T = u # States
    Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc = p # Parameters
    k(x) = k₀*exp(-Ea/8.314/x) # kinetic constant

    du[1] = dCa = (q/V)*(Caf-Ca) - k(T)*Ca # derivatie of Ca
    du[2]  = dT = (q/V)*(Tf-T) + (-ΔH/ρ/Cₚ)*k(T)*Ca + (UA/V/ρ/Cₚ)*(Tc-T) # Derivative of T

end
####################################################################

########################### PARAMETERS #############################
Ea = 72750          # activation energy J/gmol
k₀ = 7.2e10         # Arrhenius rate constant 1/min
V = 100.0           # Volume [L]
ρ = 1000.0          # Density [g/L]
Cₚ = 0.239          # Heat capacity [J/g/K]
ΔH = -5.0e4         # Enthalpy of reaction [J/mol]
UA = 5.0e4          # Heat transfer [J/min/K]
q = 100.0           # Flowrate [L/min]
Caf = 1.0           # Inlet feed concentration [mol/L]
Tf = 350.0          # Inlet feed temperature [K]
Tc = 300.0          # Coolant temperature [K]
####################################################################

########################### INITIAL COND ###########################
Ca0 = 0.5
T0 = 350.0
####################################################################

########################### SIMULATION #############################
u0 = [Ca0 , T0]
p = [Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc]
tspan = (0.0 , 10.0)
prob = ODEProblem(cstr,u0,tspan,p)
sol = solve(prob,Tsit5(),saveat=0.1)
####################################################################

########################### PLOTTING SOLUTION #############################
plot(sol,layout=(1,2))
plot(sol,vars=(1,2),ylabel="T",xlabel="Ca",title="Phase Space")
