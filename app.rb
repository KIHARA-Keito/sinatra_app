# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'uri'
require 'pg'

MEMO_DATABASE_NAME = 'memo_list'

helpers do
  def escape_text(text)
    Rack::Utils.escape_html(text)
  end
end

def read_memos
  @conn.exec('SELECT * FROM Memo')
end

def read_memo(id)
  selected_memo = read_memos.select { |item| item['id'] == id }
  selected_memo[0]
end

def add_memo(id, title, content)
  @conn.exec_params('INSERT INTO Memo (id, title, content) VALUES ($1, $2, $3)', [id, title, content])
end

def update_memo(id, title, content)
  @conn.exec_params('UPDATE Memo SET title = $1, content = $2 WHERE id = $3', [title, content, id])
end

def delete_memo(id)
  @conn.exec_params('DELETE FROM Memo WHERE id = $1', [id])
end

def decode_and_hash(request)
  Hash[URI.decode_www_form(request)]
end

def redirect_error_if_empty(post_data)
  return unless post_data['title'].empty? || post_data['content'].empty?

  redirect '/error'
  halt
end

before do
  @conn = PG.connect(dbname: MEMO_DATABASE_NAME)
end

get '/' do
  @title = 'メモ一覧'
  @memo = read_memos.to_a
  erb :index
end

get '/memo/new' do
  @title = 'メモ追加'
  erb :new
end

post '/memo' do
  post_data = decode_and_hash(request.body.read)
  redirect_error_if_empty(post_data)
  id = SecureRandom.uuid
  add_memo(id, post_data['title'], post_data['content'])
  redirect '/'
end

get '/memo/*/edit' do |id|
  @title = 'メモ編集'
  @memo = read_memo(id)
  erb :edit
end

get '/memo/*' do |id|
  @title = 'メモ詳細'
  @memo = read_memo(id)
  erb :memo
end

patch '/memo/*' do |id|
  post = decode_and_hash(request.body.read)
  redirect_error_if_empty(post)
  update_memo(id, post['title'], post['content'])
  redirect '/'
end

delete '/memo/*' do |id|
  delete_memo(id)
  redirect '/'
end

get '/error' do
  @title = 'タイトルと内容を両方入力してください'
  erb :error
end
