function parseTickets (ticketsConfig, commitMsg) {
  const tickets = []

  ticketsConfig.forEach(ticketConfig => {
    const anyMatch = commitMsg.match(ticketConfig.pattern)
    if (anyMatch) {
      for (const match of commitMsg.matchAll(ticketConfig.pattern)) {
        const name = match[1] ?? match[0]
        const link = ticketConfig.url.replace('$TICKET', name)
        const existingTicket = tickets.find(ticket => ticket.name === name)
        if (!existingTicket) {
          tickets.push({ name, link })
        }
      }
    }
  })

  return tickets
}

module.exports = {
  parseTickets
}
