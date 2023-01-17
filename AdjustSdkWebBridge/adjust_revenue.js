function AdjustAdRevenue(source) {
    this.source = source;
    this.revenue = null;
    this.currency = null;

    this.adRevenueUnit = null;
    this.adRevenueNetwork = null;
    this.adRevenuePlacement = null;

    this.adImpressionsCount = null;
    this.callbackParameters = [];
    this.partnerParameters = [];
}

AdjustAdRevenue.prototype.setAdRevenue = function(revenue, currency) {
    this.revenue = revenue;
    this.currency = currency;
};

AdjustAdRevenue.prototype.addCallbackParameter = function(key, value) {
    this.callbackParameters.push(key);
    this.callbackParameters.push(value);
};

AdjustAdRevenue.prototype.addPartnerParameter = function(key, value) {
    this.partnerParameters.push(key);
    this.partnerParameters.push(value);
};

AdjustAdRevenue.prototype.setAdImpressionsCount = function(adImpressionsCount) {
    this.adImpressionsCount = adImpressionsCount;
};

AdjustAdRevenue.prototype.setAdRevenueNetwork = function(adRevenueNetwork) {
    this.adRevenueNetwork = adRevenueNetwork;
};

AdjustAdRevenue.prototype.setAdRevenueUnit= function(adRevenueUnit) {
    this.adRevenueUnit = adRevenueUnit;
};

AdjustAdRevenue.prototype.setAdRevenuePlacement = function(adRevenuePlacement) {
    this.adRevenuePlacement = adRevenuePlacement;
};


