import React from "react";
import mar from "./images/margerita.jpg"
import veg from "./images/veg.png"
import nonveg from "./images/nonveg.png"

function Item({item, index, handleClick}){
    function showIngredients(index){
      
      if(document.getElementsByClassName('ingredients_list')[index].style.display === 'none'){
        document.getElementsByClassName('ingredients_list')[index].style.display = 'block';
      }
      else{
        document.getElementsByClassName('ingredients_list')[index].style.display = 'none';
      }
    }
    return(
        <div className="item flex">
              {
                (item.type === 'veg')? <div className="veg_nonveg"><img src={veg} alt="" /></div> : <div className="veg_nonveg"><img src={nonveg} alt="" /></div>
              }
              <div className="item_img">
                <img src= {item.url} alt="" srcset="" />
              </div>
              <div className="item_details">
              <div className="detail_box">
                <div className="item_name_div"><p className="item_name">{item.name}</p></div>
                <div className="price_and_tags flex">
                  <p className="item_price">&#x20B9; {item.price}</p>
                  {
                    (item.tags !== "") ? <p className="tag">  {item.tags}  </p> : <p></p>
                  }
                </div>
                <div className="ingredients">
                  <div className="ingredient_text_and_button flex">
                    <p className="ingredients_text">Ingredients</p>
                    <button className="ingredient_button" onClick={()=> {showIngredients(index)}}>
                      <i class="fa-solid fa-chevron-down"></i>
                    </button>
                  </div>
                  <div className="ingredients_list">
                    <p className="all_ingredients">{item.ingredients}</p>
                  </div>
                </div>
                </div>
              </div>
              <div className="add_button_div">
              <button className="add_button" onClick={()=>handleClick(item)}>ADD</button>
            </div>
            </div>
    )
}

export default Item