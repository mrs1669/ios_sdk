function AdjustEvent(eventId) {
    this.eventId = eventId;
    this.revenue = null;
    this.currency = null;
    this.deduplicationId = null;
    this.callbackParameters = [];
    this.partnerParameters = [];
}

AdjustEvent.prototype.setRevenue = function(revenue, currency) {
    this.revenue = revenue;
    this.currency = currency;
};

AdjustEvent.prototype.addCallbackParameter = function(key, value) {
    this.callbackParameters.push(key);
    this.callbackParameters.push(value);
};

AdjustEvent.prototype.addPartnerParameter = function(key, value) {
    this.partnerParameters.push(key);
    this.partnerParameters.push(value);
};

AdjustEvent.prototype.setDeduplicationId = function(deduplicationId) {
    this.deduplicationId = deduplicationId;
};

