using Plots,DifferentialEquations

########################### CSTR MODEL #############################
function cstr(du,u,p,t)

    Ca,T = u # States
    dCa,dT = du # Derivatives
    Ea,k₀,V,ρ,Cₚ,ΔH,UA,q,Caf,Tf,Tc = p # Parameters


    k(T) = k₀*exp(-Ea/8.314/T) # kinectic constant

    dCa = (q/V)*(Caf-Ca) - k(T)*Ca # derivatie of Ca
    dT = (q/V)*(Tf-T) + (-ΔH/ρ/Cₚ)*k(T)*Ca + (UA/V/ρ/Cₚ)*(Tc-T) # Derivative of T

end
####################################################################

########################### PARAMETERS #############################
Ea = 72750     
k₀ = 7.2e10    
V = 100.0     
ρ = 1000.0    
Cₚ = 0.239     
ΔH = -5.0e4 
UA = 5.0e4 
q = 100.0
Caf = 1.0
Tf = 350.0
Tc = 300.0
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
sol = solve(prob)
####################################################################

########################### PLOTTING SOLUTION #############################
plot(sol,layout=(2,1))

