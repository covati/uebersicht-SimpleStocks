# Separate stock symbols with a plus sign
#  S&P500 - %5EGSPC
#  NASDAQ - %5EIXIC
symbols = "TDC+AAPL+GD+TWTR+%5EIXIC+%5EGSPC"

# See http://www.jarloo.com/yahoo_finance/ for Yahoo Finance options
command: "curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=#{symbols}&f=sl1c1p2' | sed 's/\"//g'"

# images are from Yahoo and are of the format:
#  http://chart.finance.yahoo.com/z?s=TDC&t=2w&q=l&l=on&z=s&p=m10,m45
# s=TDC - quote name
# t=3m - time frame of X axis, m = months, w = weeks, d = days; I've seen the moving averages break with the days time period
# z=s - size: s, m, l
# p=m10,m45 - moving averages in days; don't seem to work predictably with shorter time frames

# Refresh every 5 minutes
refreshFrequency: '5m'

style: """
  bottom: 10%
  left: 5%
  color: #ABC
  font-family: Gotham


  background-color rgba(0,0,0,.01)
  -webkit-backdrop-filter blur(6px) brightness(100%) contrast(80%) saturate(140%)


  table
    border-collapse: collapse
    table-layout: fixed

    &:after
      content: 'stock pulse'
      position: absolute
      left: 0
      top: -14px
      font-size: 10px

  td
    border: 1px solid #fff
    font-size: 20px
    font-weight: 100
    width: 182px
    max-width: 182px
    overflow: hidden
    text-shadow: 0 0 1px rgba(#000, 0.5)
    background: rgba(#000, 0.3)

  .td_img
    background: none
    border: 0px solid #fff
    padding: 2px
    min-height: 110px

  .wrapper
    padding: 4px 6px 4px 6px
    position: relative


  .info
    padding: 0
    margin: 0
    font-size: 11px
    font-weight: normal
    max-width: 100%
    color: #ddd
    text-overflow: ellipsis
    text-shadow: none

  .selected
    background: rgba(#090, 0.12)

  .up
    color: #050

  .down
    color: #500

  .neutral
    color: #ccc
"""

render: -> """
  <table id='stock_quotes'><tr><td>Loading...</td></tr></table>
  <table><tr id='stock_images'  style='height:12px;'><td><div style="height:110px;"><center>Loading...</center></div></td>
  <td><div style="height:110;"><center>Loading...</center></div></td></tr></table>
"""

update: (output, domEl) ->
  stocks = output.split('\n')
  table  = $(domEl).find('#stock_quotes')
  table.html ""

# Update the charts to pick a random stock and display moving trend and recent days
  img_row  = $(domEl).find('#stock_images')
  symbol_str=stocks[Math.floor(Math.random()*(stocks.length-1))]
  img_args = symbol_str.split(',')
  symbol=img_args[0]
  img_row.html("
  <td class='td_img'><img width=182 src=\"http://chart.finance.yahoo.com/z?s=#{symbol}&t=2w&q=l&l=on&z=s&p=m10,m45\"></td>
  <td class='td_img'><img width=182 src=\"http://chart.finance.yahoo.com/z?s=#{symbol}&t=5d&q=l&l=on&z=s\"></td>")
  #img_row.html("<td style='height: 30px;'>TEST</td>")

  renderStock = (label, val, change, changepct) ->
# Use a neutral color for no change or for minor change
    direction = 'neutral'
    selected = ''
    if (changepct.charAt(0) == '+' && change>1)
        direction = 'up'
    if (changepct.charAt(0) == '-' && change*-1>1)
        direction = 'down'
# Identify which of the symbols we are showing in the charts below
    if (label == symbol)
        selected = 'selected'
    """
    <td>
      <div class='wrapper #{selected}'>
        #{label} #{val}
        <div class='info #{direction}'>#{change} (#{changepct.replace /\s/g, ''})</div>
      </div>
    </td>
    """
  for stock, i in stocks
    args = stock.split(',')
    if i % 2 == 0
      table.append "<tr/>"
    if (args[2]=='N/A')
      args[2] = '-'
    if (args[3]=='N/A')
      args[3] = "na"
    if (args[0])
      table.find("tr:last").append renderStock(args...)