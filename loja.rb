require 'sinatra'
require 'sinatra/activerecord'
require './bares.rb'
require './eventos.rb'
#require 'file'
require 'fileutils'

ActiveRecord::Base.establish_connection(:adapter => 'postgres', :database => './bares.kexi')

enable :sessions

get '/' do
	erb :inicio
end

get '/sobre' do
	erb :sobre
end

get '/bares_lista' do
  @bares = Bares.all
  erb :bares_lista
end

get '/bares_cadastro' do
  @bares = Bares.all
  erb :bares_cadastro
end

post '/bares_cadastro' do
  @novo_bar = Bares.new(:nome => params[:nome], :preco => params[:preco], :ano => params[:ano], :id_artista => params[:artista], :id_tipo => params[:tipo], :id_genero => params[:genero])
  #FileUtils.cp(params[:file][:tempfile], "public/")
  @novo_produto.save

  #FileUtils.cp(params['imagem'][:tempfile].path, "./public/#{@novo_produto.id}.jpg")
  #redirect '/'
  
  redirect '/bares_lista'
end

get '/bares_editar' do
  @bares = Bares.all
  @bares_editar = Produto.where("id IN (?)", params[:id_editar])
  erb :bares_editar
end

post '/bares_editar' do
  @bares = Bares.find(params[:id_editar])
  @bares.nome = params[:nome_editar]
  @bares.preco = params[:preco_editar]
  @bares.save

  redirect '/bares_lista'
end

post '/bares_remover' do
  @bares = Bares.find(params[:id_remover]).destroy

  redirect '/bares_lista'
end

get '/admin_cadastro' do
  #Formulário de administrador
  erb :admin_cadastro
end

post '/admin_cadastro' do
  #Cadastro de administradores no banco de dados
  if params[:senha] != nil && params[:senha] == params[:confirma_senha]
    @admin = Usuario.new(:nome => params[:nome], :email => params[:email], :senha => params[:senha], :tipo_usuario => 0)
    @admin.save
  else
    redirect '/admin_cadastro'
  end
  redirect '/'
end

post '/autenticar' do
  #TESTAR LOGIN/SENHA
  # PESQUISA SE EXISTE UM CLIENTE COM ESSE EMAIL E ESSA SENHA
  encontrado = Usuario.where("email = ? AND senha = ?", params[:email], params[:senha])
  
  if session[:admin_logado] == nil
    session[:admin_logado] = []
  end

  if session[:cliente_logado] == nil
    session[:cliente_logado] == []
  end

  if encontrado.size == 0
    # NÃO ACHOU
    redirect '/'
  else
    # ACHOU!!!!!
    #Se é administrador
    if encontrado[0].tipo_usuario == 0
      session[:admin_logado] = encontrado[0].id
    #Se é cliente
    elsif encontrado[0].tipo_usuario == 1
      session[:cliente_logado] = encontrado[0].id
    else
    redirect '/'
    end
    redirect '/'
  end
end

get '/logout' do
  #session.destroy para remover tudo (inclusive carrinho)
  session[:admin_logado] = nil
  session[:cliente_logado] = nil
  session[:id_carrinho] = nil
  session[:valor_total] = nil
  redirect '/'
end

get "/bares_busca" do
  @bares = Bares.where("nome LIKE ?", '%'+params[:busca]+'%')

  @bares_busca = params[:busca]

  erb :bares_busca
end

