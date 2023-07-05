# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'uri'
require 'pg'

MEMO_FILE_NAME = 'sampledb'
MEMO_TABLE_NAME = 'Memo'

helpers do
  def escape_text(text)
    Rack::Utils.escape_html(text)
  end
end

def read_memos(file_name)
  @conn.exec("SELECT * FROM #{file_name}")
end

def read_memo(file_name, id)
  selected_memo = read_memos(file_name).select { |item| item['id'] == id }
  selected_memo[0]
end

def add_memo(file_name, id, title, content)
  @conn.exec("INSERT INTO #{file_name} (id, title, content) VALUES ('#{id}', '#{title}', '#{content}')")
end

def update_memo(file_name, id, title, content)
  @conn.exec("UPDATE #{file_name} SET title = '#{title}', content = '#{content}' WHERE id = '#{id}'")
end

def delete_memo(file_name, id)
  @conn.exec("DELETE FROM #{file_name} WHERE id='#{id}'")
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
  @conn = PG.connect(dbname: MEMO_FILE_NAME)
end

get '/' do
  @title = 'メモ一覧'
  @memo = read_memos(MEMO_TABLE_NAME)
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
  title = post_data['title']
  content = post_data['content']
  add_memo(MEMO_TABLE_NAME, id, title, content)
  redirect '/'
end

get '/memo/*/edit' do |id|
  @title = 'メモ編集'
  @memo = read_memo(MEMO_TABLE_NAME, id)
  erb :edit
end

get '/memo/*' do |id|
  @title = 'メモ詳細'
  @memo = read_memo(MEMO_TABLE_NAME, id)
  erb :memo
end

patch '/memo/*' do |id|
  post = decode_and_hash(request.body.read)
  redirect_error_if_empty(post)
  memos_data = read_memos(MEMO_TABLE_NAME)
  memos_data.each_with_index do |memo, index|
    memos_data[index] = { 'id' => id, 'title' => post['title'], 'content' => post['content'] } if memo['id'] == id
  end
  write_memo(MEMO_TABLE_NAME, memos_data)
  redirect '/'
end

delete '/memo/*' do |id|
  delete_memo(MEMO_TABLE_NAME, id)
  redirect '/'
end

get '/error' do
  @title = 'タイトルと内容を両方入力してください'
  erb :error
end
