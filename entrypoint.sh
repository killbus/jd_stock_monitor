#!/usr/bin/env bash
# 需要替换的参数：
# CHAT_ID='-1001325237796' 目标群或者频道ID
# TOKEN="BOT TOKEN"        BOT的TOKEN
# 购买地区：
# cityId，townId，countyId 可以在"配送至" - "选择新地址"，审查元素，查看对应地区的id

#
# Display settings on standard out.
#
echo "settings"
echo "================"
echo
echo "  Skuids:                     ${SKUIDS}"
echo "  TG_CHAT_ID:                 ${TG_CHAT_ID}"
echo "  TG_TOKEN:                   ${TG_TOKEN}"
echo "  PROVINCEID:                 ${PROVINCEID}"
echo "  CITYID:                     ${CITYID}"
echo "  TOWNID:                     ${TOWNID}"
echo "  COUNTYID:                   ${COUNTYID}"
echo

declare -A inStockSkuids

while true; do
    for id in $SKUIDS; do

        res=$(curl -s "https://c0.3.cn/stocks?type=getstocks&skuIds=$id&area=${PROVINCEID}_${CITYID}_${TOWNID}_${COUNTYID}" -H 'Connection: keep-alive' -H 'Accept: */*' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8')
        stockstate=$(echo $res | jq -r '.[]["StockState"]')
        skustate=$(echo $res | jq -r '.[]["skuState"]')
        if [ "$stockstate" == 33 ] && [ "$skustate" == 1 ]; then
            instock=${inStockSkuids[$id]}
            if [ "$instock" != 1 ]; then
                TEXT="SKUID: $id\nSTOCK: 有货 \nLink: https://item.jd.com/$id.html"
                echo -e $TEXT | curl -G --data-urlencode text@- "https://api.telegram.org/bot$TG_TOKEN/sendMessage?chat_id=$TG_CHAT_ID"
            fi

            inStockSkuids[$id]=1
        else
            inStockSkuids[$id]=0
        fi
        echo "SKUID: $id StockState(33): $stockstate skuState(1): $skustate Link: https://item.jd.com/$id.html"
        sleep 1.$(( ( RANDOM % 10 )  + 1 ))
    done
done

# StockState: 33 有货 34 无货
# skuState:   1  上架 0  下架
# example
# 上架了无货
# {"1612617211":{"StockState":34,"freshEdi":null,"ab":"-1","ac":"-1","ad":"-1","ae":"-1","skuState":1,"PopType":0,"af":"-1","ag":"-1","sidDely":"163","channel":1,"StockStateName":"无货","rid":"110008301","m":"0","sid":"163","rfg":0,"dcId":"6","ArrivalDate":"","v":"0","IsPurchase":false,"rn":-1,"eb":"99","ec":"-1"}}

# 上架了有货
# {"65444576694":{"StockState":33,"freshEdi":null,"ab":"-1","ac":"-1","ad":"-1","ae":"-1","skuState":1,"PopType":0,"af":"-1","ag":"-1","sidDely":"-1","channel":1,"StockStateName":"现货","rid":null,"m":"0","sid":"-1","rfg":0,"dcId":"-1","ArrivalDate":"","v":"0","IsPurchase":false,"rn":-1,"eb":"99","ec":"-1"}}

# 下架有货
# {"65444576693":{"StockState":33,"freshEdi":null,"ab":"-1","ac":"-1","ad":"-1","ae":"-1","skuState":0,"PopType":0,"af":"-1","ag":"-1","sidDely":"-1","channel":1,"StockStateName":"现货","rid":null,"m":"0","sid":"-1","rfg":0,"dcId":"-1","ArrivalDate":"","v":"0","IsPurchase":false,"rn":3,"eb":"99","ec":"-1"}}
