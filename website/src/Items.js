import React, { useContext, useEffect, useState } from "react";
import Item from "./Item";
import { app, database } from "./firebaseConfig"
import { collection, getDocs, query, where } from "firebase/firestore"
import { categoryContext, typeContext } from "./App";

function Items({handleClick}){
    const {selectedCategory} = useContext(categoryContext);
    const {selectedType} = useContext(typeContext);
    const [array, setArray] = useState([]);
    const dbInstance = collection(database, 'items');

    const getData = async() => {
      const data = await getDocs(dbInstance);
      console.log(data);
      setArray(data.docs.map((item) => {
        return {...item.data(), id: item.id}
      }));
    }

      useEffect(()=>{
        getData();
        //eslint-disable-next-line
      }, []);

      
      function FilterItemData(itemData, selectedCategory, selectedType){
          const [filteredDate, setFilteredData] = useState([]);

          useEffect(() => {
              let data;

              if(selectedCategory === "all"){
                if(selectedType === 'all'){
                  data = itemData;
                }
                else{
                  console.log(selectedType);
                  data = itemData.filter(item => item.type === selectedType);
                }
              }
              else{
                if(selectedType === 'all'){
                  data = itemData.filter(item => item.category === selectedCategory);
                }
                else{
                  data = itemData.filter(item => item.category === selectedCategory && item.type === selectedType);
                }
              }

              setFilteredData(data);
          }, [itemData, selectedCategory, selectedType])

          return filteredDate
      }

      const filterList = FilterItemData(array, selectedCategory, selectedType);

    return(
        <div className="items">

            {
              filterList.map( (item,index) => 
                <Item item={item} key={item.key} index = {index} handleClick = {handleClick} />
            )
            }
        </div>
    )
}


export default Items