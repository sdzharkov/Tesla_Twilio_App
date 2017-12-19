import React from 'react';
import { inject, observer } from 'mobx-react';
import Cable from 'actioncable';
import ReactTable from 'react-table';
import "react-table/react-table.css";

@inject('CrudStore')
@observer export default class CrudTable extends React.Component {


  componentWillMount() {
    this.createSocket();
    this.props.CrudStore.fetchUsers();
  }

  createSocket = () => {
    let cable = Cable.createConsumer('ws://localhost:3001/cable');
    this.chats = cable.subscriptions.create({
      channel: 'CrudChannel'
    }, {
      connected: () => {
        console.log('connected');
      },
      received: (data) => {
        this.props.CrudStore.updateData(data.users);
      }
    });
  }

  render() {
    const columns = [{
      Header: 'ID',
      accessor: 'id'
    }, {
      Header: 'Name',
      accessor: 'name'
    }, {
      Header: 'Created At',
      accessor: 'created_at'
    }, {
      Header: 'Updated At',
      accessor: 'updated_at'
    }];

    return (
      <div className="react-table-container">
        <ReactTable
          data={this.props.CrudStore.data.slice()}
          columns={columns}
        />
      </div>
    )
  }
}
