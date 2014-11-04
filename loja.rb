require 'sinatra'
require 'sinatra/activerecord'
require './bares.rb'
require './eventos.rb'
#require 'file'
require 'fileutils'

#Faz a conexão com o banco de dados. adapter informa qual o banco de dados, e database informa o nome do arquivo do banco de dados.
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => './bares.db')

enable :sessions

#informa qual a ação na "raiz" do site (quando tiver só o endereço mesmo. www.nomedosite.com/)
get '/' do
	#aponta qual o arquivo erb (html com código ruby) vai ser exibido na "raiz" do site
	erb :inicio
end

#informa qual a ação na página "sobre" do site (quando tiver só o endereço mesmo. www.nomedosite.com/sobre)
get '/sobre' do
	#aponta qual o arquivo erb (html com código ruby) vai ser exibido na página "sobre" do site
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

#função que controla o método post do form bares_cadastro (na página bares_cadastro)
post '/bares_cadastro' do
  #Cria uma nova variável do tipo "bares" e atribui os valores dos campos (params[:nome_do_campo] se refere ao campo nome_do_campo no form bares_cadastro
  @novo_bar = Bares.new(:Nome => params[:nome], :Descricao => params[:descricao], :Endereco => params[:endereco], :Telefone => params[:telefone], :Email => params[:email], :DiasFunc => params[:diasfunc])
  #salva a variável no banco
  @novo_bar.save

  #redireciona para a lista de bares
  redirect '/bares_lista'
end

get '/bares_editar' do
  #cria uma variável que recebe todos os dados da tabela bares (a classe Bares se refere à tabela bares do banco de dados)
  @bares = Bares.all
  #pesquisa um dado específico (onde o if for params[:id_editar], que é um campo oculto no html
  @bares_editar = Bares.where("IdBar IN (?)", params[:id_editar])
  erb :bares_editar
end

post '/bares_editar' do
  #pesquisa o dado pelo id específico passado como parâmetro
  @bares = Bares.find(params[:id_editar])
  @bares.Nome = params[:nome_editar]
  @bares.Descricao = params[:descricao_editar]
  @bares.Endereco = params[:endereco_editar]
  @bares.Telefone = params[:telefone_editar]
  @bares.Email = params[:email_editar]
  @bares.DiasFunc = params[:diasfunc_editar]
  @bares.save

  redirect '/bares_lista'
end

post '/bares_remover' do
  #procura o dado pelo id, e exclui permanentemente da tabela
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

  erb :bares_lista
end

