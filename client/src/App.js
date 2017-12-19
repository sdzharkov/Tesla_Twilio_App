import React, { Component } from 'react';
import CrudTable from './components/CrudTable';
import './App.css';

class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <h1 className="App-title">Tesla Twilio Data Stream</h1>
          <h3>Text CRUD commands and watch them happen.</h3>
        </header>
        <CrudTable />
      </div>
    );
  }
}

export default App;
