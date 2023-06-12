import React, { useState } from "react";
import Items from "./Items";

function Top({setSelectedCategory, setShow, handleClick, category, warning, added, setSelectedType}){
    const [veg, setVeg] = useState(false);
    const [nonveg, setNonveg] = useState(false);

    function setCheck(value){
      if(value === 'veg' && !veg){
        setVeg(true);
        console.log("Find Veg");
        setSelectedType('veg');
        if(nonveg){
          setNonveg(false);
          document.getElementById("nonvegcheckbox").checked = false;
        }
      }
      else if(value === 'veg' && veg){
        console.log("Dont Find Veg");
        setVeg(false);
        setSelectedType('all');
      }
      else if(value === 'nonveg' && !nonveg){
        setNonveg(true);
        console.log("Find Non Veg");
        setSelectedType('nonveg');
        if(veg){
          setVeg(false);
          document.getElementById("vegcheckbox").checked = false;
        }
      }
      else if(value === 'nonveg' && nonveg){
        setNonveg(false);
        console.log("Dont Find Non Veg");
        setSelectedType('all');
      }
    }

    return(
      <div className="App">
      {
        warning && <div className="warning message">
          <p>&#x26D4; Item Already Exist</p>
          <div className="line"></div>
        </div>
      }
      {
        added && <div className="added message">
          <p><i className="fa-solid fa-circle-check" style={{color: '#1df519'}}></i> Item Added Succesfully</p>
          <div className="line"></div>
        </div>
      }


      <div className="heading flex" >
        <div className="restaurant_name_div">
          <p className="restaurant_name_text text-2xl font-bold">
            Domino's Pizza
          </p>
        </div>
        <div className="cart_button_div">
          <button className="cart_button" onClick={() => setShow(false)}>
            <i class="fa-solid fa-cart-shopping"></i>
          </button>
        </div>
      </div>

      <div className="menu_div">
        <p className="menu_text">Menu</p>
      </div>

      <div className="typeDiv">
          <input type="checkbox" value={veg} id="vegcheckbox"  onChange={() => setCheck('veg')}/>
          <label htmlFor="veg" className="vegLabel">Only Veg</label>
          <input type="checkbox" value={nonveg} id="nonvegcheckbox" onChange={() => setCheck('nonveg')}/>
          <label htmlFor="veg" className="nonvegLabel">Only Non-Veg</label>
      </div>

      <div className="filters grid-flow-row pl-2 pr-2 pt-3">
          <button className="filter" onClick={() => {setSelectedCategory("all")}}>All</button>
          <button className="filter" onClick={() => {setSelectedCategory("Recommended")}}>Recommended</button>
        {
          category.map((item) => {
          return(
            <button className="filter" onClick={() => {setSelectedCategory(item)}}>{item}</button>
          )
        })}
      </div>

      <Items handleClick = {handleClick}/>
      
    </div>
    )
}

export default Top