import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import App from './App'

describe('App', () => {
  afterEach(() => vi.restoreAllMocks())

  it('loads and creates a work item', async () => {
    const fetchMock = vi.spyOn(globalThis, 'fetch')
      .mockResolvedValueOnce(new Response(JSON.stringify([]), { status: 200 }))
      .mockResolvedValueOnce(new Response(JSON.stringify({ id: '1' }), { status: 201 }))
      .mockResolvedValueOnce(new Response(JSON.stringify([{
        id: '1',
        title: 'Adapt the domain',
        description: null,
        status: 'todo',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      }]), { status: 200 }))

    render(<App />)
    expect(await screen.findByText('No work items yet.')).toBeInTheDocument()

    await userEvent.type(screen.getByLabelText('New work item'), 'Adapt the domain')
    await userEvent.click(screen.getByRole('button', { name: 'Add' }))

    expect(await screen.findByText('Adapt the domain')).toBeInTheDocument()
    expect(fetchMock).toHaveBeenNthCalledWith(2, expect.stringContaining('/api/work-items'), expect.objectContaining({
      method: 'POST',
    }))
  })

  it('shows a useful error when the API cannot be reached', async () => {
    vi.spyOn(globalThis, 'fetch').mockRejectedValue(new Error('Network unavailable'))
    render(<App />)
    await waitFor(() => expect(screen.getByRole('alert')).toHaveTextContent('Network unavailable'))
  })
})
