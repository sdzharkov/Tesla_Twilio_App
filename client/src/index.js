import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';
import { Provider } from 'mobx-react';
import { useStrict } from 'mobx';
import CrudStore from './containers/CrudStore';
useStrict(true);

ReactDOM.render(
  <Provider CrudStore={CrudStore} >
    <App />
  </Provider>, 
  document.getElementById('root'));
registerServiceWorker();
