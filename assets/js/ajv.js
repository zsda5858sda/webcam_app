var idCheck = function (val) {
    return new Promise(function (resolve, reject) {
        val = val.trim().toUpperCase();
        if (val.match("^[A-Z][12]\\d{8}$|^[A-Z][12]\\d{8}[B-C]$")) {
            if (val.match("^[A-Z][12]\\d{8}[B-C]$")) {
                val = val.slice(0, 10)
            }

            let conver = "ABCDEFGHJKLMNPQRSTUVXYWZIO"
            let weights = [1, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1]
            checkSum = 0
            val = String(conver.indexOf(val[0]) + 10) + val.slice(1);

            for (let i = 0; i < val.length; i++) {
                c = parseInt(val[i])
                w = weights[i]
                checkSum += c * w
            }
            // if(checkSum % 10 == 0){ //新式身分證和舊式改為可被'5'整除
            if (checkSum % 10 == 0) {
                resolve({
                    msg: "身分證格式正確",
                    resault: true
                })
            } else {
                resolve({
                    msg: "身分證格式錯誤",
                    resault: false
                })
            }
        } else {
            resolve({
                msg: "身分證格式錯誤",
                resault: false
            })
        }
    })
}
// 身份證 end

// 統一編號 begin
var taxIdCheck = function (val) {
    return new Promise(function (resolve, reject) {
        val = val.trim().toUpperCase();
        if (val.match("^\\d{8}$")) {

            const invalidList = "11111111,00000000";

            if (invalidList.indexOf(val) != -1) {
                resolve({
                    msg: "統一編號格式錯誤",
                    resault: false
                })
            } else {
                let validateOperator = [1, 2, 1, 2, 1, 2, 4, 1]
                let sum = 0;
                let calculate = function (product) {
                    let ones = product % 10,
                        tens = (product - ones) / 10;
                    return ones + tens;
                };
                for (let i = 0; i < validateOperator.length; i++) {
                    sum += calculate(val[i] * validateOperator[i]);
                }
                if (sum % 10 == 0 || (val[6] == "7" && sum % 10 == 9)) {
                    resolve({
                        msg: "統一編號格式正確",
                        resault: true
                    })
                } else {
                    resolve({
                        msg: "統一編號格式錯誤",
                        resault: false
                    })
                }
            }
        } else {
            resolve({
                msg: "統一編號格式錯誤",
                resault: false
            })
        }
    })
}

// 統一編號 end

// 境外法人虛擬統一編號格 begin
var virtualtaxIdCheck = function (val) {
    return new Promise(function (resolve, reject) {
        val = val.trim().toUpperCase();
        if (val.match("^[A-Z]{4}\\d{5,8}$")) {
            resolve({
                msg: "境外法人虛擬統一編號格式正確",
                resault: true
            })
        } else {
            resolve({
                msg: "境外法人虛擬統一編號格式錯誤",
                resault: false
            })
        }
    })
}
// 境外法人虛擬統一編號格 end

// 聯名戶或分行提供之虛擬統一編號begin
var JointAccountVirtualtaxIdCheck = function (val) {
    return new Promise(function (resolve, reject) {
        val = val.trim().toUpperCase();
        if (val.match("^\\d{8}[B]$")) {
            resolve({
                msg: "聯名戶或分行提供之虛擬統一編號格式正確",
                resault: true
            })
        } else {
            resolve({
                msg: "聯名戶或分行提供之虛擬統一編號格式錯誤",
                resault: false
            })
        }
    })
}
// 聯名戶或分行提供之虛擬統一編號 end

// 居留證 begin
var alienResidentCertificateNoCheck = function (val) {
    return new Promise(function (resolve, reject) {
        val = val.trim().toUpperCase();
        if (val.match(/^[A-Z][A-D]\d{8}$/) || val.match(/^[A-Z][8-9]\d{8}$/)) {

            const tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const a1 = new Array(10, 11, 12, 13, 14, 15, 16, 17, 34, 18, 19, 20, 21, 22, 35, 23, 24, 25, 26, 27, 28, 29, 32, 30, 31, 33);
            const mx = new Array(1, 8, 7, 6, 5, 4, 3, 2, 1);

            if (val.match(/^[A-Z][A-D]\d{8}$/)) {//舊式
                //第一碼
                const i1 = tab.indexOf(val.charAt(0));
                const n1 = ((Math.floor(a1[i1] / 10)) + (a1[i1] % 10 * 9)) % 10;//第一碼對映數字
                //第二碼
                const i2 = tab.indexOf(val.charAt(1));
                const n2 = a1[i2] % 10;//第二碼對映數字

                var convertId = n1.toString() + n2.toString() + val.substr(2, 8);
                var sum = 0;
                //計算加總
                for (i = 0; i < 9; i++) {
                    v = parseInt(convertId.charAt(i));
                    if (isNaN(v)) {
                        resolve({
                            msg: "居留證格式錯誤",
                            resault: false
                        })
                    }
                    sum = sum + v * mx[i];
                }
                if (((10 - sum % 10) != val.charAt(9)) && (sum % 10 != 0)) {
                    resolve({
                        msg: "居留證格式錯誤",
                        resault: false
                    })
                }
                resolve({
                    msg: "居留證格式正確",
                    resault: true
                })
            } else if (val.match(/^[A-Z][8-9]\d{8}$/)) {//新式
                const a1 = new Array(10, 11, 12, 13, 14, 15, 16, 17, 34, 18, 19, 20, 21, 22, 35, 23, 24, 25, 26, 27, 28, 29, 32, 30, 31, 33);
                const mx = new Array(1, 8, 7, 6, 5, 4, 3, 2, 1);
                // 第一碼
                const i1 = tab.indexOf(val.charAt(0));//判斷第一碼在第幾位
                const n1 = ((Math.floor(a1[i1] / 10)) + (a1[i1] % 10 * 9)) % 10;//第一碼對映數字

                var convertId = n1.toString() + val.substr(1, 8);
                var sum = 0;
                //計算加總
                for (i = 0; i < 9; i++) {
                    v = parseInt(convertId.charAt(i));
                    if (isNaN(v)) {
                        resolve({
                            msg: "居留證格式錯誤",
                            resault: false
                        })
                    }
                    sum = sum + v * mx[i];
                }
                //判斷
                if (((10 - sum % 10) != val.charAt(9)) && (sum % 10 != 0)) {
                    -
                    resolve({
                        msg: "居留證格式錯誤",
                        resault: false
                    })
                }
                resolve({
                    msg: "居留證格式正確",
                    resault: true
                })
            } else {
                resolve({
                    msg: "居留證格式錯誤",
                    resault: false
                })
            }

        } else {
            resolve({
                msg: "居留證格式錯誤",
                resault: false
            })
        }
    })
}
// 居留證 end

// 稅籍號碼(護照) begin
var passportNoCheck = function (val) {
    return new Promise(function (resolve, reject) {
        val = val.trim().toUpperCase();
        if (val.match(/^[0-9]{4}[0-1][0-9][0-3][0-9][A-Z]{2}[C]$/)) {
            let dateArray = [];
            let limitInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

            dateArray[0] = val.slice(0, 4);
            dateArray[1] = val.slice(4, 6);
            dateArray[2] = val.slice(6, 8);

            let theYear = parseInt(dateArray[0]);
            let theMonth = parseInt(dateArray[1]);
            let theDay = parseInt(dateArray[2]);
            let isLeap = new Date(theYear, 1, 29).getDate() === 29;// 判斷輸入的年份是否為閏年?

            let todaySec = new Date(new Date().toLocaleDateString()).getTime();
            let inputDaySec = new Date(theYear + '/' + theMonth + '/' + theDay).getTime();
            let currentYear = new Date().getFullYear();
            let currentMonth = new Date().getMonth() + 1;
            let currentDay = new Date().getDate();

            if (isLeap) {
                // 若為閏年，最大日期限制改為 29
                limitInMonth[1] = 29;
            }

            if (theDay <= limitInMonth[theMonth - 1] && inputDaySec < todaySec) {
                if ((currentYear - theYear) > 7) {
                    resolve({
                        msg: "稅籍編號格式正確",
                        resault: true
                    })
                } else if ((currentYear - theYear) == 7 && theMonth < currentMonth) {
                    resolve({
                        msg: "稅籍編號格式正確",
                        resault: true
                    })
                } else if ((currentYear - theYear) == 7 && theMonth == currentMonth && theDay <= currentDay) {
                    resolve({
                        msg: "稅籍編號格式正確",
                        resault: true
                    })
                } else {
                    resolve({
                        msg: "申請人年齡未滿7歲",
                        resault: false
                    })
                }
            } else {
                resolve({
                    msg: "稅籍編號格式錯誤",
                    resault: false
                })
            }

        } else {
            resolve({
                msg: "稅籍編號格式錯誤",
                resault: false
            })
        }
    })
}
// 稅籍號碼 end



function mixCheck(inputID) {
    return new Promise(function (resolve, reject) {
        Promise.all([
            this.idCheck(inputID),
            this.taxIdCheck(inputID),
            this.virtualtaxIdCheck(inputID),
            this.JointAccountVirtualtaxIdCheck(inputID),
            this.alienResidentCertificateNoCheck(inputID),
            this.passportNoCheck(inputID)])
            .then(value => {
                let index = value.findIndex(x => x.resault === true)
                resolve({
                    'validateResult': index != -1 ? value[index].resault : false,
                    'validateResultMsg': index != -1 ? value[index].msg : '',
                    'detailResult': value
                });
            })
            .catch(err => {
                console.log(err.message)
                reject(err.message);
            })
    })
}

function finalCheck(inputId) {
    let res = mixCheck(inputID);
    let pr = Promise.resolve(res);
    pr.then(function (val) {
        return  JSON.stringify({ "object": "成功"});
    })
}