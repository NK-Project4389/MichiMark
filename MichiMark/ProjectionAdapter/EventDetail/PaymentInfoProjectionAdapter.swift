struct PaymentInfoProjectionAdapter {

    func adapt(payments: [PaymentDomain]) -> PaymentInfoProjection {

        let validPayments = payments.filter { !$0.isDeleted }

        let items = validPayments
            .sorted { $0.paymentSeq < $1.paymentSeq }
            .map { adaptItem($0) }

        let total = validPayments.reduce(0) { $0 + $1.paymentAmount }

        return PaymentInfoProjection(
            items: items,
            displayTotalAmount: "\(total) 円"
        )
    }

    private func adaptItem(_ domain: PaymentDomain) -> PaymentItemProjection {
        PaymentItemProjection(
            id: domain.id,
            displayAmount: "\(domain.paymentAmount) 円",
            payer: MemberItemProjection(domain: domain.paymentMember),
            splitMembers: domain.splitMembers.map {
                MemberItemProjection(domain: $0)
            },
            memo: domain.paymentMemo
        )
    }
}
