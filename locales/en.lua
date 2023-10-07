local Translations = {

    lang_s1 = 'Open Ranch Shop',
    lang_s2 = 'Ranch Shop Owner Menu',
    lang_s3 = 'View Shop Items',
    lang_s4 = 'view the ranch shop items',
    lang_s5 = 'Refill Ranch Shop',
    lang_s6 = 'refill your stock',
    lang_s7 = 'View Ranch Money',
    lang_s8 = 'check and withdraw ranch shop money',
    lang_s9 = 'Ranch Shop Customer Menu',
    lang_s10 = 'Ranch Shop',
    lang_s11 = 'view items for sale',
    lang_s12 = 'Unit price: $',
    lang_s13 = 'Shop Menu',
    lang_s14 = 'Ranch Stock',
    lang_s15 = 'How many?',
    lang_s16 = 'must have the amount in your inventory',
    lang_s17 = 'Sell Price',
    lang_s18 = 'example: 0.10',
    lang_s19 = 'Something went wrong, check you have the correct amount and price!',
    lang_s20 = 'Invalid Amount',
    lang_s21 = 'Balance : $',
    lang_s22 = 'Withdraw money',
    lang_s23 = 'The money will be given to you in cash!',
    lang_s24 = 'Max Withdraw: $',
    lang_s25 = '(case sensitive box)',
    lang_s26 = 'added to ranch shop',
    lang_s27 = 'added to ranch shop',
    lang_s28 = 'You lack money',
    lang_s29 = 'No Items',
    lang_s30 = 'no stock items to add',
    lang_s31 = 'stock replenishment',

}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
