require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require './bares.rb'
require './eventos.rb'
require './usuarios.rb'
require 'tempfile'
require 'fileutils'

#Faz a conexão com o banco de dados. adapter informa qual o banco de dados, e database informa o nome do arquivo do banco de dados.
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => './bares.db')

use Rack::Session::Cookie
#enable :sessions

#informa qual a ação na "raiz" do site (quando tiver só o endereço mesmo. www.nomedosite.com/)
get '/' do
	#aponta qual o arquivo erb (html com código ruby) vai ser exibido na "raiz" do site
  
	@bares = Bares.all
	@eventos = Eventos.all

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

get '/eventos_lista' do

  @eventos = Eventos.all
  erb :eventos_lista
end

get '/bares_cadastro' do
  @bares = Bares.all
  erb :bares_cadastro
end

get '/eventos_cadastro' do
  @eventos = Eventos.all
  @bares = Bares.all
  erb :eventos_cadastro
end

#função que controla o método post do form bares_cadastro (na página bares_cadastro)
post '/bares_cadastro' do
  #Cria uma nova variável do tipo "bares" e atribui os valores dos campos (params[:nome_do_campo] se refere ao campo nome_do_campo no form bares_cadastro
  @novo_bar = Bares.new(:Nome => params[:nome], :Descricao => params[:descricao], :Endereco => params[:endereco], :Telefone => params[:telefone],
     :Email => params[:email], :DiasFunc => params[:diasfunc], :Hinicio => params[:hinicio], :Hfim => params[:hfim])
  #salva a variável no banco
  @novo_bar.save

  file = params['imagem']
  tmp = file[:tempfile]
  FileUtils.cp(tmp.path, "./public/bares/#{@novo_bar.IdBar}.jpg")
    
  #redireciona para a lista de bares
  redirect '/bares_lista'
end

post '/eventos_cadastro' do
  #Cria uma nova variável do tipo "bares" e atribui os valores dos campos (params[:nome_do_campo] se refere ao campo nome_do_campo no form bares_cadastro
  @novo_evento = Eventos.new(:Titulo => params[:titulo], :Descricao => params[:descricao], :Local => params[:local], 
    :Data => params[:data], :Hora => params[:hora], :IdBar => params[:bar])
  #salva a variável no banco
  @novo_evento.save
  
  file = params['imagem']
  tmp = file[:tempfile]
   FileUtils.cp(tmp.path, "./public/eventos/#{@novo_evento.IdEvento}.jpg")
    
  redirect '/eventos_lista'
end

get '/bar_visualizar' do 

  @bar = Bares.where("IdBar IN (?)", params[:id_visualizar])
  erb :bar

end

get '/evento_visualizar' do 

  @eventos = Eventos.where("IdEvento IN (?)", params[:id_visualizar])
  erb :evento

end

get '/bares_editar' do
  #cria uma variável que recebe todos os dados da tabela bares (a classe Bares se refere à tabela bares do banco de dados)
  @bares = Bares.all
  #pesquisa um dado específico (onde o if for params[:id_editar], que é um campo oculto no html
  @bares_editar = Bares.where("IdBar IN (?)", params[:id_editar])
  erb :bares_editar
end

get '/eventos_editar' do
  #cria uma variável que recebe todos os dados da tabela bares (a classe Bares se refere à tabela bares do banco de dados)
  @eventos = Eventos.all
  @bares = Bares.all
  #pesquisa um dado específico (onde o if for params[:id_editar], que é um campo oculto no html
  @eventos_editar = Eventos.where("IdEvento IN (?)", params[:id_editar])
  erb :eventos_editar
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
  @bares.Hinicio = params[:hinicio]
  @bares.Hfim = params[:hfim]
  @bares.save

  redirect '/bares_lista'
end

post '/eventos_editar' do

  @eventos = Eventos.find(params[:id_editar])
  @eventos.Titulo = params[:titulo_editar]
  @eventos.Descricao = params[:descricao_editar]
  @eventos.Local = params[:local_editar]
  @eventos.Data = params[:data_editar]
  @eventos.Hora = params[:hora_editar]
  @eventos.IdBar = params[:bar_editar]
  @eventos.save

  redirect '/eventos_lista'

end

post '/bares_remover' do
  #procura o dado pelo id, e exclui permanentemente da tabela
  @bares = Bares.find(params[:id_remover]).destroy

  redirect '/bares_lista'
end

post '/eventos_remover' do
  #procura o dado pelo id, e exclui permanentemente da tabela
  @eventos = Eventos.find(params[:id_remover]).destroy

  redirect '/eventos_lista'
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

get '/login' do
  erb :login
end

post '/autenticar' do
  #TESTAR LOGIN/SENHA
  # PESQUISA SE EXISTE UM CLIENTE COM ESSE EMAIL E ESSA SENHA
  @msg = ""
  encontrado = Usuarios.where("email = ? AND senha = ?", params[:email], params[:senha])
  
  if session[:admin_logado] == nil
    session[:admin_logado] = []
  end

  if encontrado.size == 0
    # NÃO ACHOU
    redirect '/login'
  else
    # ACHOU!!!!!
    session[:admin_logado] = encontrado[0].id
    redirect '/'
  end

end

get '/logout' do
  #session.destroy para remover tudo (inclusive carrinho)
  session[:admin_logado] = nil
  redirect '/'
end

get "/bares_busca" do
  @bares = Bares.where("nome LIKE ?", '%'+params[:busca]+'%')

  @bares_busca = params[:busca]

  erb :bares_lista
end

