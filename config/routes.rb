Spree::Core::Engine.add_routes do
  get 'pagseguro/callback' => 'pagseguro#callback', as: :pagseguro_callback
  post 'pagseguro/notify' => 'pagseguro#notify', as: :pagseguro_notify
end
