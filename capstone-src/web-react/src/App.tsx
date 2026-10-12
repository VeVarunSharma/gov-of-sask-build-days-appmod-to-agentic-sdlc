import { useCallback, useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import './App.css'

export type WorkItem = {
  id: string
  title: string
  description: string | null
  status: 'todo' | 'in_progress' | 'done'
  createdAt: string
  updatedAt: string
}

const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080').replace(/\/$/, '')

function App() {
  const [items, setItems] = useState<WorkItem[]>([])
  const [title, setTitle] = useState('')
  const [error, setError] = useState('')

  const loadItems = useCallback(async () => {
    try {
      const response = await fetch(`${apiBaseUrl}/api/work-items`)
      if (!response.ok) throw new Error('Could not load work items.')
      setItems(await response.json())
      setError('')
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'Unexpected error.')
    }
  }, [])

  useEffect(() => {
    void loadItems()
  }, [loadItems])

  async function addItem(event: FormEvent) {
    event.preventDefault()
    const trimmedTitle = title.trim()
    if (!trimmedTitle) return

    const response = await fetch(`${apiBaseUrl}/api/work-items`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: trimmedTitle, description: null, status: 'todo' }),
    })

    if (!response.ok) {
      setError('Could not create the work item.')
      return
    }

    setTitle('')
    await loadItems()
  }

  async function toggleItem(item: WorkItem) {
    const nextStatus = item.status === 'done' ? 'todo' : 'done'
    const response = await fetch(`${apiBaseUrl}/api/work-items/${item.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title: item.title,
        description: item.description,
        status: nextStatus,
      }),
    })

    if (!response.ok) {
      setError('Could not update the work item.')
      return
    }

    await loadItems()
  }

  async function deleteItem(id: string) {
    const response = await fetch(`${apiBaseUrl}/api/work-items/${id}`, { method: 'DELETE' })
    if (!response.ok) {
      setError('Could not delete the work item.')
      return
    }
    await loadItems()
  }

  return (
    <main>
      <header>
        <p className="eyebrow">Capstone starter</p>
        <h1>Work items</h1>
        <p>Replace this neutral domain with your team’s scenario.</p>
      </header>

      <form onSubmit={addItem}>
        <label htmlFor="title">New work item</label>
        <div className="input-row">
          <input
            id="title"
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            placeholder="Describe the next task"
          />
          <button type="submit">Add</button>
        </div>
      </form>

      {error && <p role="alert" className="error">{error}</p>}

      <section aria-live="polite">
        <h2>Current work</h2>
        {items.length === 0 ? (
          <p className="empty">No work items yet.</p>
        ) : (
          <ul>
            {items.map((item) => (
              <li key={item.id}>
                <button
                  className={`status ${item.status === 'done' ? 'complete' : ''}`}
                  onClick={() => void toggleItem(item)}
                  aria-label={`Mark ${item.title} as ${item.status === 'done' ? 'todo' : 'done'}`}
                >
                  {item.status === 'done' ? '✓' : '○'}
                </button>
                <span className={item.status === 'done' ? 'done' : ''}>{item.title}</span>
                <button className="delete" onClick={() => void deleteItem(item.id)}>Delete</button>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  )
}

export default App
