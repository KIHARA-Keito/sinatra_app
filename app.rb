# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'uri'

MEMO_FILE_NAME = 'memo.json'

helpers do
  def escape_text(text)
    Rack::Utils.escape_html(text)
  end
end

def read_memo(file_name, id: false)
  memo = File.open(file_name, 'r') { |file| JSON.parse(file.read) }
  if id
    selected_memo = memo.select { |item| item['id'] == id }
    selected_memo[0]
  else
    memo
  end
end

def write_memo(file_name, memo)
  File.open(file_name, 'w') { |file| JSON.dump(memo, file) }
end

def decode_and_hash(request)
  Hash[URI.decode_www_form(request)]
end

def redirect_error_if_empty(post_data)
  return unless post_data['title'].empty? || post_data['body'].empty?

  redirect '/error'
  halt
end

get '/' do
  @title = 'メモ一覧'
  @memo = read_memo(MEMO_FILE_NAME)
  erb :index
end

get '/memo/new' do
  @title = 'メモ追加'
  erb :new
end

post '/memo' do
  post_data = decode_and_hash(request.body.read)
  redirect_error_if_empty(post_data)
  id = SecureRandom.uuid.to_s
  memo_data = read_memo(MEMO_FILE_NAME)
  add_data = { 'id' => id, 'title' => post_data['title'], 'body' => post_data['body'] }
  memo_data.push(add_data)
  write_memo(MEMO_FILE_NAME, memo_data)
  redirect '/'
end

get '/memo/*/edit' do |id|
  @title = 'メモ編集'
  @memo = read_memo(MEMO_FILE_NAME, id: id)
  erb :edit
end

get '/memo/*' do |id|
  @title = 'メモ詳細'
  @memo = read_memo(MEMO_FILE_NAME, id: id)
  erb :memo
end

patch '/memo/*' do |id|
  post_data = decode_and_hash(request.body.read)
  redirect_error_if_empty(post_data)
  memo_data = read_memo(MEMO_FILE_NAME)
  memo_data.each_with_index do |memo, index|
    memo_data[index] = { 'id' => id, 'title' => post_data['title'], 'body' => post_data['body'] } if memo['id'] == id
  end
  write_memo(MEMO_FILE_NAME, memo_data)
  redirect '/'
end

delete '/memo/*' do |id|
  memo_data = read_memo(MEMO_FILE_NAME)
  selected_memo = memo_data.reject { |item| item['id'] == id }
  write_memo(MEMO_FILE_NAME, selected_memo)
  redirect '/'
end

get '/error' do
  @title = 'タイトルと内容を両方入力してください'
  erb :error
end
