import "./index.css"
import {useState, useEffect, createContext, useContext} from 'react'
import { database } from "./firebaseConfig"
import { collection, getDocs } from "firebase/firestore"
import Cart from "./Cart"
import Top from "./Top"
import "core-js/features/array/at"

const categoryContext = createContext();
function CategoryContextProvider({children}){
  const defaultCategory = "all";
  const [selectedCategory, setSelectedCategory] = useState(defaultCategory);

  return(
    <categoryContext.Provider value={
      {
        selectedCategory,
        setSelectedCategory
      }
    }>
      {children}
    </categoryContext.Provider>
  )
}

const typeContext = createContext();
function TypeContextProvider({children}){
  const defaultType = "all";
  const [selectedType, setSelectedType] = useState(defaultType);

  return(
    <typeContext.Provider value={
      {
        selectedType,
        setSelectedType
      }
    }>
      {children}
    </typeContext.Provider>
  )
}

const localCart = JSON.parse(localStorage.getItem('cart'));
console.log((localCart.length), "Carta");

function App() {

  const [category, setCategory] = useState([]);
  const [show, setShow] = useState(true);
  const [cart, setCart] = useState(localCart);
  const [warning, setWarning] = useState(false);
  const [added, setAdded] = useState(false);
  const dbInstance = collection(database, 'items');

  
  const allCategory = async () => {
    const catArray = [];
    const data = await getDocs(dbInstance);
    const myData = data.docs.map((item) => {
      return {...item.data(), id: item.id}
    });
    for(var i = 0; i < myData.length; i++){
      if(!catArray.includes(myData[i].category)){
        catArray.push(myData[i].category);
      }
    }
    setCategory(catArray);
  }
  
  function setDisable(i){
    console.log(i);
    document.getElementsByClassName('decreaseItem')[i].setAttribute('disabled', 'disabled');
  }

  function handleClick(item){
      let isPresent = false;
      cart.forEach((i) => {
        if(i.name === item.name){
          isPresent = true;
        }
      });

      if(!isPresent){
        item.quantity = 1;
        setCart([...cart, item]);
        setAdded(true);
        setTimeout(() => {
          setAdded(false);
        }, 2000);
      }
      else{
        setWarning(true);
        setTimeout(() => {
          setWarning(false);
        }, 2000);
      }
  }

  const onRemove = (item) =>{
    const afterRemoveData = cart.filter((i) => i.id !== item.id);
    setCart(afterRemoveData);
  }

  const onChange = (item, d) => {
    let ind = -1;
    cart.forEach((i, index) => {
      if(i.id === item.id){
        ind = index;
      }
    });
    const tempArr = cart;
    tempArr[ind].quantity += d;
    if(tempArr[ind].quantity === 1){
      setDisable(ind);
    }
    setCart([...tempArr]);
  }




  useEffect(()=>{
    allCategory();
    //eslint-disable-next-line
  }, []);

  useEffect(()=>{
    localStorage.setItem('cart', JSON.stringify(cart));
  }, [cart]);

  const {setSelectedCategory} = useContext(categoryContext);
  const {setSelectedType} = useContext(typeContext);

  return (

    <div className="main">
      <div className="tribute" >
        <p className="tribute_text pt-1 pr-2 pl-2 pb-1 text-xl font-medium text-white text-center">A Tribute To Alan Turing . . .</p>
      </div>
      {
        show ? <Top handleClick = {handleClick} setSelectedCategory = {setSelectedCategory} setShow={setShow} category = {category} warning = {warning} added = {added} setSelectedType = {setSelectedType}/> : <Cart cart={ cart} onRemove = {onRemove} onChange={onChange} setShow={setShow} setCart= {setCart}/>     
      }

      <div className="made_with_love">
        <p className="made_with_love_text">
          We Love You <span>&#x2764;</span> Mr. Turing . . .
        </p>
      </div>
    </div>
    

  );
}

export default App;

export {categoryContext, CategoryContextProvider};
export {typeContext, TypeContextProvider};
