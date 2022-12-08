
function AdjustRevenue(source) {
    this.source = source;
    this.revenue = null;
    this.currency = null;
    this.adImpressionsCount = null;
    this.callbackParameters = [];
    this.partnerParameters = [];
}

AdjustRevenue.prototype.setRevenue = function(revenue, currency) {
    this.revenue = revenue;
    this.currency = currency;
};

AdjustRevenue.prototype.addCallbackParameter = function(key, value) {
    this.callbackParameters.push(key);
    this.callbackParameters.push(value);
};

AdjustRevenue.prototype.addPartnerParameter = function(key, value) {
    this.partnerParameters.push(key);
    this.partnerParameters.push(value);
};

AdjustRevenue.prototype.setAdImpressionsCount = function(adImpressionsCount) {
    this.adImpressionsCount = adImpressionsCount;
};

