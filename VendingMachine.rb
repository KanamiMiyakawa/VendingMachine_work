
module ItemManagement
  attr_reader :slot_money, :sales_money
  def initialize
    @slot_money = 0
    @sales_money = 0
    @managing = false
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

  def item_menu
    sleep(0.5)
    puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
    puts "　＝管理機能＝ アイテムメニューです"
    puts "ここまでの売上金額:#{self.sales_money}"
    puts "0:商品追加\n1:商品削除\n2:商品確認\n3:在庫補充\n4:メニューにもどる"
    case choice
    when 0
      if @items.size == @item_limit
        p "商品は#{@item_limit}個までしか格納できません、先に商品を削除してください"
        item_menu
      else
        item_add
      end
    when 1
      item_delete
    when 2
      display
      item_menu
    when 3
      item_restore
    when 4
      @managing = false
      menu
    else
      p "有効な数字を入力してください"
      item_menu
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
    @items << {price: price, name: name, quantity: quantity, max: quantity}
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

  def item_restore
    check_password
    display
    p "在庫補充する商品の番号を入力"
    select_item = gets.chomp.to_i
    @items[select_item][:quantity] = @items[select_item][:max]
    puts "商品番号：#{select_item} 名前：#{@items[select_item][:name]}を#{@items[select_item][:max]}個に補充しました"
    item_menu
  end

  def can_buy?(n)
    if @managing && @items[n][:quantity] > 0
      true
    elsif self.slot_money >= @items[n][:price] && @items[n][:quantity] > 0
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

  def choice
    gets.chomp.to_i
  end
end

class VendingMachineModel
  include ItemManagement
  MONEY = [10, 50, 100, 500, 1000].freeze

  def initialize
    super
    @items = []
    @items << {price:120,name:'cola',quantity:5,max:5}
    @items << {price:100,name:'water',quantity:5,max:5}
    @items << {price:200,name:'redbull',quantity:5,max:5}
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
    # menu <= コメントアウト
  end

  def get_item(n)
    @items[n][:quantity] -= 1
    @sales_money += @items[n][:price]
    print "#{@items[n][:name]}を購入しました！"
    sleep(0.5)
    puts "ガタン"
    @slot_money -= @items[n][:price]
    sleep(0.5)
    menu
  end
end

class VendingMachineInterface < VendingMachineModel
  def initialize
    super
    puts "いらっしゃいませ！！"
    menu
  end

  def menu
    sleep(0.5)
    puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
    puts 'メニューです‼'
    display
    puts "合計金額：#{@slot_money}"
    puts "0:コイン投入\n1:商品選択\n2:払い戻し\n3:商品管理画面\n4:購入を終了する"
    case choice
    when 0
      throw_money_interface
    when 1
      select_item
    when 2
      return_money
      menu # <= 追加
    when 3
      check_password
      @managing = true
      item_menu
    when 4
      return_money if @slot_money != 0 # <= 追加
      puts "買い物を終了しました\nありがとうございました！"
    else
      puts "適切な数字を入れてください"
      menu
    end
    puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
  end

  def throw_money_interface
    puts "お金を入れてください\n10, 50, 100, 500, 1000"
    money = gets.chomp.to_i
    throw_money(money)
    puts "合計：#{@slot_money}"
    puts "0:コイン投入を続ける\n1:メニューへ"
    case choice
    when 0
      throw_money_interface
    when 1
      menu
    else
      puts "入力が適切な数字ではありません\nメニューへ戻ります"
      menu
    end
  end

  def select_item
    puts '商品番号を選択してください'
    select = choice
    if select < @items.size && can_buy?(select)
      get_item(select)
    else
      if select >= @items.size
        puts "\n入力した商品番号は存在しません\n"
      else
        puts "\n商品の在庫がないか、投入金額が足りません\n"
      end
      puts "0:商品選択へ戻る\n1:メニューへ\n"
      case choice
      when 0
        select_item
      else
        menu
      end
    end
  end

end

#ItemManagement.new
vm = VendingMachineInterface.new
