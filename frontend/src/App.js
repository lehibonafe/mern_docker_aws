import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

function App() {
  const [items, setItems] = useState([]);
  const [newItem, setNewItem] = useState({ name: '', description: '' });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/items`);
      setItems(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch items. Make sure the backend is running.');
      console.error('Error fetching items:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!newItem.name || !newItem.description) {
      alert('Please fill in all fields');
      return;
    }

    try {
      await axios.post(`${API_URL}/api/items`, newItem);
      setNewItem({ name: '', description: '' });
      fetchItems();
    } catch (err) {
      setError('Failed to create item');
      console.error('Error creating item:', err);
    }
  };

  const handleToggle = async (id, completed) => {
    try {
      await axios.put(`${API_URL}/api/items/${id}`, { completed: !completed });
      fetchItems();
    } catch (err) {
      setError('Failed to update item');
      console.error('Error updating item:', err);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this item?')) {
      try {
        await axios.delete(`${API_URL}/api/items/${id}`);
        fetchItems();
      } catch (err) {
        setError('Failed to delete item');
        console.error('Error deleting item:', err);
      }
    }
  };

  return (
    <div className="App">
      <div className="container">
        <header className="header">
          <h1>📝 MERN Task Manager</h1>
          <p>Built with MongoDB, Express, React & Node.js</p>
        </header>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        <div className="form-container">
          <h2>Add New Task</h2>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Task name"
              value={newItem.name}
              onChange={(e) => setNewItem({ ...newItem, name: e.target.value })}
              className="input"
            />
            <textarea
              placeholder="Task description"
              value={newItem.description}
              onChange={(e) => setNewItem({ ...newItem, description: e.target.value })}
              className="textarea"
              rows="3"
            />
            <button type="submit" className="btn btn-primary">
              Add Task
            </button>
          </form>
        </div>

        <div className="items-container">
          <h2>Tasks ({items.length})</h2>
          {loading ? (
            <div className="loading">Loading tasks...</div>
          ) : items.length === 0 ? (
            <div className="no-items">No tasks yet. Create your first task above!</div>
          ) : (
            <div className="items-list">
              {items.map((item) => (
                <div key={item._id} className={`item-card ${item.completed ? 'completed' : ''}`}>
                  <div className="item-content">
                    <h3>{item.name}</h3>
                    <p>{item.description}</p>
                    <small className="item-date">
                      {new Date(item.createdAt).toLocaleDateString()}
                    </small>
                  </div>
                  <div className="item-actions">
                    <button
                      onClick={() => handleToggle(item._id, item.completed)}
                      className={`btn ${item.completed ? 'btn-secondary' : 'btn-success'}`}
                    >
                      {item.completed ? '↩️ Undo' : '✓ Complete'}
                    </button>
                    <button
                      onClick={() => handleDelete(item._id)}
                      className="btn btn-danger"
                    >
                      🗑️ Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;