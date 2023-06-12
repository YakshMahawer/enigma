import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { categoryContext, CategoryContextProvider, typeContext, TypeContextProvider } from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <CategoryContextProvider>
      <TypeContextProvider>
        <App />
      </TypeContextProvider>
    </CategoryContextProvider>
  </React.StrictMode>
);

