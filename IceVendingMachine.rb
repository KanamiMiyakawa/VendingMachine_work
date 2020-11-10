
module ItemManagement

  def initialize
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

  def item_add
    p 'パスワードを入力してください'
    password = gets.chomp
    if password.to_s == @password
      p '値段を設定してください'
      price = gets.to_i
      p '商品名を設定してください'
      name = gets.chomp.to_s
      p '初期在庫数を設定してください'
      quantity = gets.to_i
      @items << {price: price, name: name, quantity: quantity}
      item_menu
    end
  end

  def item_delete
    p 'パスワードを入力してください'
    password = gets.chomp
    if password.to_s == @password
      display
      p "削除する商品の番号を入力"
      select_item = gets.chomp.to_i
      puts "商品番号#{select_item} 名前：#{@items[select_item][:name]}を削除しました"
      @items.delete_at(select_item)
      item_menu
    end
  end

  def display
    n = 0
    puts "\n---------------------------"
    @items.each do |item|
      puts "\n商品番号：#{n}\n名前：#{item[:name]}\n値段：#{item[:price]}\n在庫：#{item[:quantity]}"
      if can_buy?(n)
        ">購入できます<"
      else
        ">現在購入できません<"
      end
      puts "\n---------------------------\n"
      n += 1
    end
  end

  def item_menu
    puts "0:商品追加\n1:商品削除\n2:商品確認\n3:メニューにもどる"
    choice = gets.chomp.to_i
    if choice == 0
      if @items.size == 3
        p "商品は３つまでしか格納できません、先に商品を削除してください"
        item_menu
      else
        item_add
      end
    elsif choice == 1
      item_delete
    elsif choice == 2
      display
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


# ↓ IceVendingMachineはここから下を変える必要がある




class VendingMachineModel
  include ItemManagement
  attr_reader :slot_money, :sales_money
  MONEY = [10, 50, 100, 500, 1000].freeze

  def initialize
    super
    @slot_money = 0
    @sales_money = 0
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
    puts @slot_money
    @slot_money = 0
  end

  def select_item
    puts '商品番号を選択してください'
    select = gets.chomp.to_i
    if select < @items.size
      get_item(select)
    else
      puts "\n商品番号を確認してください\n"
      sleep(1)
      menu
    end
  end

  def can_buy?(n)
    if @slot_money >= @items[n][:price] && @items[n][:quantity] > 0
      true
    else
      false
    end
  end

  def get_item(n)
    if can_buy?(n)
      @items[n][:quantity] -= 1
      @sales_money += @items[n][:price]
      puts "#{@items[n][:name]}を購入しました！ガタン"
      @slot_money -= @items[n][:price]
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

  def before_throw_money
    puts "お金を入れてください\n10, 50, 100, 500, 1000"
    money = gets.chomp.to_i
    throw_money(money)
  end

  def throw_money(money)
    super
    after_throw_money
  end

  def after_throw_money
    puts "合計：#{@slot_money}"
    puts "0:コイン投入を続ける\n1:メニューへ\n2:払い戻し"
    choice = gets.chomp.to_i
    if choice == 0
      before_throw_money
    elsif choice == 1
      menu
    elsif choice == 2
      return_money
    else
      puts "適切な数字を入れてください"
      after_throw_money
    end
  end

  def before_get_item
    if can_buy?
      puts "購入できます"
    else
      puts "購入できません"
    end
    puts "購入しますか？"
    puts "0:購入する\n1:メニューへ"
    choice = gets.chomp.to_i
    if choice == 0
      get_item
    elsif choice == 1
      menu
    else
      puts "適切な数字を入れてください"
      before_get_item
    end
  end

  def menu
    puts 'メニューです‼'
    display
    puts "合計金額：#{@slot_money}"
    puts "0:コイン投入\n1:商品選択\n2:払い戻し\n3:商品管理画面"
    choice = gets.chomp.to_i
    case choice
    when 0
      before_throw_money
    when 1
      select_item
    when 2
      return_money
    when 3
      item_menu
    else
      puts "適切な数字を入れてください"
      menu
    end
  end
end

#ItemManagement.new
vm = VendingMachineInterface.new