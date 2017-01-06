# Separate stock symbols with a plus sign
symbols = "TDC+AAPL+GOOG+TWTR+%5EIXIC+%5EGSPC"

# See http://www.jarloo.com/yahoo_finance/ for Yahoo Finance options
command: "curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=#{symbols}&f=sl1c1p2' | sed 's/\"//g'"

# Refresh every 5 minutes
refreshFrequency: 300000

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

  .up
    color: #050

  .down
    color: #500

  .neutral
    color: #ccc
"""

render: -> """
  <table><tr><td>Loading...</td></tr></table>
"""

update: (output, domEl) ->
  stocks = output.split('\n')
  table  = $(domEl).find('table')
  table.html ""

  renderStock = (label, val, change, changepct) ->
# Use a neutral color for no change or for minor change
    direction = 'neutral'
#    direction = if (changepct.charAt(0) == '+') then 'up' else 'down'
#    direction = if (changepct.charAt(0) == '+' && change>2) then 'up'
#    direction = if (changepct.charAt(0) == '-') then 'down'
    if (changepct.charAt(0) == '+' && change>1)
        direction = 'up'
    if (changepct.charAt(0) == '-' && change*-1>1)
        direction = 'down'

    """
    <td>
      <div class='wrapper'>
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
