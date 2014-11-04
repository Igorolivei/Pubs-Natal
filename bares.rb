#o ActiveRecord pega do banco de dados a tabela com o nome bares, e cria a classe de acordo com seus atributos. Ex.: se tem uma coluna "nome" na tabela do banco de dados, automaticamente a classe terá um atributo também chamado "nome"
class Bares < ActiveRecord::Base
end
