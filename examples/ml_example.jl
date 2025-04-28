using Pkg; Pkg.activate(".")
using SciGlassDatabase

load_essentials()

comps = "SiO2-Na2O-MgO"
df = get_compositions(;property=["Density"], composition=comps)

# data for ML
y = Float32.(df.DENSITY')
x = Float32.(hcat(df.SIO2, df.NA2O, df.MGO)')

using Flux
using Flux: train!
using Plots
using Statistics

normalize(x) = (x .- mean(x)) ./ std(x)

x = normalize(x)
y = normalize(y)


# Define model
model = Chain(Dense(3, 10), Dense(10, 10), Dense(10, 1))
ps = Flux.params(model)
loss(model, x, y) = Flux.Losses.mse(model(x), y)

# optimizer
opt = Adam()
opt_state = Flux.setup(opt, model)

# Compute initial predictions and loss
loss_0 = loss(model, x, y)

println("Initial loss: $loss_0")

# Zip the train before so we can pass it to the training function
data = [(x, y)]
n_epochs = 1000

loss_values = zeros(1000)

for epoch in 1:n_epochs
    train!(loss, model, data, opt_state)
    loss_values[epoch] = loss(model, x, y)
    if epoch % 10 == 0
        println("Epoch: $epoch, loss: ", loss_values[epoch])
    end
end

Plots.plot(loss_values, label=nothing)
xlabel!("Epochs")
ylabel!("Loss")



