Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root :to => redirect('/interface/wave_stacking')
  get '/interface/wave_stacking', to: 'interface#wave_stacking'
  get '/interface/pseudo_pwm', to: 'interface#pseudo_pwm'

  post '/generate/wavetable', to: 'generator#wavetable'
end
