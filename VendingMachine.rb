
module ItemManagement
  attr_reader :slot_money, :sales_money
  def initialize
    @slot_money = 0
    @sales_money = 0
    p "初期設定：商品を入れ替えるための初期パスワードを設定してください"
    @password = gets.chomp.to_s
    puts "初期設定：いくつまでの商品を格納できるようにしますか？\n３以上の数を入力してください"
    loop do
      n = gets.chomp.to_i
      if n > 2
        @item_limit = n
        break
      else
        p "有効な数字かつ3以上を入力してください"
      end
    end
  end

  def check_password
    p 'パスワードを入力してください'
    password = gets.chomp
    unless password.to_s == @password
      puts "パスワードが間違っています"
      menu
    end
  end

  def item_add
    check_password
    p '値段を設定してください'
    price = gets.to_i
    p '商品名を設定してください'
    name = gets.chomp.to_s
    p '初期在庫数を設定してください'
    quantity = gets.to_i
    @items << {price: price, name: name, quantity: quantity}
    item_menu
  end

  def item_delete
    check_password
    display
    p "削除する商品の番号を入力"
    select_item = gets.chomp.to_i
    puts "商品番号#{select_item} 名前：#{@items[select_item][:name]}を削除しました"
    @items.delete_at(select_item)
    item_menu
  end

  def can_buy?(n)
    if self.slot_money >= @items[n][:price] && @items[n][:quantity] > 0
      true
    else
      false
    end
  end

  def display
    n = 0
    puts "\n------------------------------------------\n"
    @items.each do |item|
      puts "\n商品番号：#{n}\n名前：#{item[:name]}\n値段：#{item[:price]}\n在庫：#{item[:quantity]}"
      if can_buy?(n)
        puts ">購入できます<"
      else
        puts ">現在購入できません<"
      end
      puts "\n------------------------------------------\n"
      n += 1
    end
  end

  def item_menu
    puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
    puts "【 管理機能 】アイテムメニューです"
    puts "ここまでの売上金額:#{self.sales_money}"
    puts "0:商品追加\n1:商品削除\n2:商品確認\n3:メニューにもどる"
    choice = gets.chomp.to_i
    if choice == 0
      if @items.size == @item_limit
        p "商品は#{@item_limit}個までしか格納できません、先に商品を削除してください"
        item_menu
      else
        item_add
      end
    elsif choice == 1
      item_delete
    elsif choice == 2
      display
      item_menu
    elsif choice == 3
      menu
    else
      p "有効な数字を入力してください"
      item_menu
    end
  end
end

# VendingMachineはデータ保持や加工を担当 railsのモデルのような働き
# VendingMachineInterfaceはメソッドをを繋ぎ、インターフェイスをやる

class VendingMachineModel
  include ItemManagement
  MONEY = [10, 50, 100, 500, 1000].freeze

  def initialize
    super
    @items = []
    @items << {price:120,name:'cola',quantity:5}
    @items << {price:100,name:'water',quantity:5}
    @items << {price:200,name:'redbull',quantity:5}
  end

  def throw_money(money)
    if MONEY.include?(money)
      @slot_money += money
    else
      puts "この#{money}円は取り扱いできません"
      money
    end
  end

  def return_money
    puts "#{@slot_money}円返却しました"
    @slot_money = 0
    menu
  end

  def select_item
    puts '商品番号を選択してください'
    select = gets.chomp.to_i
    if select < @items.size
      get_item(select)
    else
      puts "\n入力した商品番号は存在しません\n0:商品選択\n1:戻る\n"
      choice = gets.chomp.to_i
      case choice
      when 0
        select_item
      else
        menu
      end
    end
  end

  

  def get_item(n)
    if can_buy?(n)
      @items[n][:quantity] -= 1
      @sales_money += @items[n][:price]
      print "#{@items[n][:name]}を購入しました！"
      sleep(0.5)
      puts "ガタン"
      @slot_money -= @items[n][:price]
      sleep(0.5)
      menu
    else
      p "買えません"
      @slot_money
      select_item
    end
  end
end

class VendingMachineInterface < VendingMachineModel
  def initialize
    super
    puts "いらっしゃいませ！！"
    menu
  end

  def throw_money_interface
    puts "お金を入れてください\n10, 50, 100, 500, 1000"
    money = gets.chomp.to_i
    throw_money(money)
    puts "合計：#{@slot_money}"
    puts "0:コイン投入を続ける\n1:戻る"
    choice = gets.chomp.to_i
    if choice == 1
      menu
    else
      puts "適切な数字を入れてください" if choice != 0
      throw_money_interface 
    end
  end

  def menu
    sleep(0.5)
    puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
    puts 'メニューです‼'
    display
    puts "合計金額：#{@slot_money}"
    puts "0:コイン投入\n1:商品選択\n2:払い戻し\n3:商品管理画面\n4:購入を終了する"
    choice = gets.chomp.to_i
    case choice
    when 0
      throw_money_interface
    when 1
      select_item
    when 2
      return_money
    when 3
      check_password
      item_menu
    when 4
      puts "買い物を終了しました\nありがとうございました！"
    else
      puts "適切な数字を入れてください"
      menu
    end
    puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
  end
end

#ItemManagement.new
vm = VendingMachineInterface.new
