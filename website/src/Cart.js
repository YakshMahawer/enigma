import React, { useEffect, useState } from "react";
import easyinvoice from "easyinvoice";



function Cart({cart, onRemove, onChange, setShow, setCart}){
    function downloadInvoice(){
        var invoiceCart = cart;
        invoiceCart.forEach((i) =>{
            i.taxRate = 0;
            i.description = i.name;
            delete i.category;
            delete i.id;
            delete i.ingredients;
            delete i.status;
            delete i.tags;
            delete i.type;
            i.price = Number(i.price);
        });
        var data = {
            // Customize enables you to provide your own templates
            // Please review the documentation for instructions and examples
            "customize": {
                //  "template": fs.readFileSync('template.html', 'base64') // Must be base64 encoded html 
            },
            "images": {
                // The logo on top of your invoice
                "logo": "https://public.easyinvoice.cloud/img/logo_en_original.png",
            },
            // Your own data
            "sender": {
                "company": "Restaurant Name",
                "city": "Vadodara",
                "country": "India"
                //"custom1": "custom value 1",
                //"custom2": "custom value 2",
                //"custom3": "custom value 3"
            },
            "information": {
                // Invoice number
                "number": "2021.0001",
                // Invoice data
                "date": "12-12-2021",
            },
            // The products you would like to see on your invoice
            // Total values are being calculated automatically
            "products": invoiceCart,
            // The message you would like to display on the bottom of your invoice
            "bottom-notice": "",
            // Settings to customize your invoice
            "settings": {
                "currency": "INR", // See documentation 'Locales and Currency' for more info. Leave empty for no currency.
                // "locale": "nl-NL", // Defaults to en-US, used for number formatting (See documentation 'Locales and Currency')        
                // "margin-top": 25, // Defaults to '25'
                // "margin-right": 25, // Defaults to '25'
                // "margin-left": 25, // Defaults to '25'
                // "margin-bottom": 25, // Defaults to '25'
                // "format": "A4", // Defaults to A4, options: A3, A4, A5, Legal, Letter, Tabloid
                // "height": "1000px", // allowed units: mm, cm, in, px
                // "width": "500px", // allowed units: mm, cm, in, px
                // "orientation": "landscape", // portrait or landscape, defaults to portrait
            },
            // Translate your invoice to your preferred language
            "translate": {
                // "invoice": "FACTUUR",  // Default to 'INVOICE'
                // "number": "Nummer", // Defaults to 'Number'
                // "date": "Datum", // Default to 'Date'
                // "due-date": "Verloopdatum", // Defaults to 'Due Date'
                // "subtotal": "Subtotaal", // Defaults to 'Subtotal'
                // "products": "Producten", // Defaults to 'Products'
                // "quantity": "Aantal", // Default to 'Quantity'
                // "price": "Prijs", // Defaults to 'Price'
                // "product-total": "Totaal", // Defaults to 'Total'
                // "total": "Totaal", // Defaults to 'Total'
                // "vat": "btw" // Defaults to 'vat'
                "tax-rate": "tax"
            },
        };
        
        //Create your invoice! Easy!
        easyinvoice.createInvoice(data, function (result) {
            //The response will contain a base64 encoded PDF file
            easyinvoice.download("invoice.pdf", result.pdf);
            setCart([]);
        });

        setDownload(true);
        setTimeout(()=>{
            setDownload(false);
        }, 2000);

    }

    const [total, setTotal] = useState(0);
    const [download, setDownload] = useState(false);

    const handlePrice = ()=>{
        let ans = 0;
        cart.forEach((item) => {
            ans += Number(item.price) * item.quantity;
        });
        setTotal(ans);
        console.log(cart);
    }
 


    useEffect(()=>{
        handlePrice();
    })
    return(
        <div className="cart">
            <div className="your_cart_div flex">
                <button><i className="fa-solid fa-left-long text-3xl" style={{color: '#171717'}} onClick={() => setShow(true)}></i></button>
                <p className="your_cart_text">Your Cart</p>
            </div>
            {
                download && <div className="downloadStarted message">Download will be started shortly...<div className="line"></div></div>
            }
            {  
                (cart.length == 0) ? <div className="no_cart_item">No Item In Your Cart</div> : 
                cart.map( item => 
                    <div className="cart_item flex">
                        <div className="name">{item.name}</div>
                        <div className="price">&#x20B9; {item.price}</div>
                        <div className="quantity_buttons flex">
                        <button onClick={()=> onChange(item, 1)} className="updown">+</button>
                            <p>{item.quantity}</p>
                            {
                                (item.quantity === 1) ? <button onClick={()=> onChange(item, -1)} className="decreaseItem updown" disabled>-</button> : <button onClick={()=> onChange(item, -1)} className="decreaseItem updown">-</button>
                            }
                        </div>
                        <button onClick={() => onRemove(item)} className="remove_button"><i className="fa-solid fa-trash" style={{color: '#ef1d06'}}></i></button>
                    </div>
                )
            }
            <div className="payment flex">
                <p>TOTAL - &#x20B9;  {total}</p>
                <button onClick={() => downloadInvoice()} className="order_food">ORDER</button>
            </div>
        </div>
    )
}

export default Cart