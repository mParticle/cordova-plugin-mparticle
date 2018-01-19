'use strict'

var cordova = require('cordova')

var exec = function (action, args) {
  cordova.exec(function (winParam) {},
                 function (error) { console.log(error) },
                 'MParticle',
                 action,
                 args)
}

var mparticle = {
  EventType: {
    Navigation: 1,
    Location: 2,
    Search: 3,
    Transaction: 4,
    UserContent: 5,
    UserPreference: 6,
    Social: 7,
    Other: 8
  },

  UserAttributeType: {
    FirstName: '$FirstName',
    LastName: '$LastName',
    Address: '$Address',
    State: '$State',
    City: '$City',
    Zipcode: '$Zip',
    Country: '$Country',
    Age: '$Age',
    Gender: '$Gender',
    MobileNumber: '$Mobile'
  },

  UserIdentityType: {
    Other: 0,
    CustomerId: 1,
    Facebook: 2,
    Twitter: 3,
    Google: 4,
    Microsoft: 5,
    Yahoo: 6,
    Email: 7,
    Alias: 8,
    FacebookCustomAudienceId: 9
  },

  ProductActionType: {
    AddToCart: 1,
    RemoveFromCart: 2,
    Checkout: 3,
    CheckoutOption: 4,
    Click: 5,
    ViewDetail: 6,
    Purchase: 7,
    Refund: 8,
    AddToWishlist: 9,
    RemoveFromWishlist: 10
  },

  PromotionActionType: {
    View: 0,
    Click: 1
  },

  start: function (key, secret) {
    exec('start',[key, secret]);
  },

  logEvent: function (eventName, type, attributes) {
    exec('logEvent', [eventName, type, attributes])
  },

  logCommerceEvent: function (commerceEvent) {
    exec('logCommerceEvent', [commerceEvent])
  },

  logScreenEvent: function (screenName, attributes) {
    exec('logScreenEvent', [screenName, attributes])
  },

  setUserAttribute: function (key, value) {
    if (value && value.constructor === Array) {
      exec('setUserAttributeArray', [key, value])
    } else {
      exec('setUserAttribute', [key, value])
    }
  },

  setUserAttributeArray: function (key, values) {
    exec('setUserAttributeArray', [key, values])
  },

  setUserTag: function (tag) {
    exec('setUserTag', [tag])
  },

  removeUserAttribute: function (key) {
    exec('removeUserAttribute', [key])
  },

  setUserIdentity: function (userIdentity, identityType) {
    exec('setUserIdentity', [userIdentity, identityType])
  },

  Impression: function (impressionListName, products) {
    this.impressionListName = impressionListName
    this.products = products
  },

  Promotion: function (id, name, creative, position) {
    this.id = id
    this.name = name
    this.creative = creative
    this.position = position
  },

  Product: function (name, sku, price, quantity) {
    this.name = name
    this.sku = sku
    this.price = price
    this.quantity = quantity

    this.setBrand = function (brand) {
      this.brand = brand
      return this
    }

    this.setCouponCode = function (couponCode) {
      this.couponCode = couponCode
      return this
    }

    this.setPosition = function (position) {
      this.position = position
      return this
    }

    this.setCategory = function (category) {
      this.category = category
      return this
    }

    this.setVariant = function (variant) {
      this.variant = variant
      return this
    }

    this.setCustomAttributes = function (customAttributes) {
      this.customAttributes = customAttributes
      return this
    }
  },

  TransactionAttributes: function (transactionId) {
    this.transactionId = transactionId

    this.setAffiliation = function (affiliation) {
      this.affiliation = affiliation
      return this
    }

    this.setRevenue = function (revenue) {
      this.revenue = revenue
      return this
    }

    this.setShipping = function (shipping) {
      this.shipping = shipping
      return this
    }

    this.setTax = function (tax) {
      this.tax = tax
      return this
    }

    this.setCouponCode = function (couponCode) {
      this.couponCode = couponCode
      return this
    }
  },

  CommerceEvent: function () {
    this.setTransactionAttributes = function (transactionAttributes) {
      this.transactionAttributes = transactionAttributes
      return this
    }

    this.setProductActionType = function (productActionType) {
      this.productActionType = productActionType
      return this
    }

    this.setPromotionActionType = function (promotionActionType) {
      this.promotionActionType = promotionActionType
      return this
    }

    this.setProducts = function (products) {
      this.products = products
      return this
    }

    this.setPromotions = function (promotions) {
      this.promotions = promotions
      return this
    }

    this.setImpressions = function (impressions) {
      this.impressions = impressions
      return this
    }

    this.setScreenName = function (screenName) {
      this.screenName = screenName
      return this
    }

    this.setCurrency = function (currency) {
      this.currency = currency
      return this
    }

    this.setCustomAttributes = function (customAttributes) {
      this.customAttributes = customAttributes
      return this
    }

    this.setCheckoutOptions = function (checkoutOptions) {
      this.checkoutOptions = checkoutOptions
      return this
    }

    this.setProductActionListName = function (productActionListName) {
      this.productActionListName = productActionListName
      return this
    }

    this.setProductActionListSource = function (productActionListSource) {
      this.productActionListSource = productActionListSource
      return this
    }

    this.setCheckoutStep = function (checkoutStep) {
      this.checkoutStep = checkoutStep
      return this
    }

    this.setNonInteractive = function (nonInteractive) {
      this.nonInteractive = nonInteractive
      return this
    }
  }
}

mparticle.CommerceEvent.createProductActionEvent = function (productActionType, products, transactionAttributes) {
  return new mparticle.CommerceEvent()
                  .setProductActionType(productActionType)
                  .setProducts(products)
                  .setTransactionAttributes(transactionAttributes)
}

mparticle.CommerceEvent.createPromotionEvent = function (promotionActionType, promotions) {
  return new mparticle.CommerceEvent()
                  .setPromotionActionType(promotionActionType)
                  .setPromotions(promotions)
}

mparticle.CommerceEvent.createImpressionEvent = function (impressions) {
  return new mparticle.CommerceEvent()
                  .setImpressions(impressions)
}

module.exports = mparticle
