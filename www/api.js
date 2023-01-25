const exec = require("cordova/exec")

const service = "EpsonTMPrinterService"

exports.printReceipt = (props, success, error) => {
    const {printerSeries, lines, includeCustomerCopy = false} = props
    const args = [printerSeries, lines, includeCustomerCopy]

    exec(success, error, service, "printReceipt", args)
}

exports.startPrinterSearch = () => {
    exec(null, null, service, "startPrinterSearch")
}

exports.stopPrinterSearch = () => {
    exec(null, null, service, "stopPrinterSearch")
}
