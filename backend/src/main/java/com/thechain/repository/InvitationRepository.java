package com.thechain.repository;

import com.thechain.entity.Invitation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvitationRepository extends JpaRepository<Invitation, UUID> {

    Optional<Invitation> findByInviteePosition(Integer inviteePosition);

    Optional<Invitation> findByInviterPosition(Integer inviterPosition);

    List<Invitation> findAllByInviterPosition(Integer inviterPosition);

    List<Invitation> findAllByInviterPositionAndStatus(Integer inviterPosition, Invitation.InvitationStatus status);

    @Query("SELECT i FROM Invitation i WHERE i.inviterPosition = :position AND i.status = 'ACTIVE'")
    Optional<Invitation> findActiveInvitationByInviterPosition(@Param("position") Integer position);

    @Query("SELECT COUNT(i) FROM Invitation i WHERE i.status = 'ACTIVE'")
    long countActiveInvitations();

    boolean existsByInviteePositionAndStatus(Integer inviteePosition, Invitation.InvitationStatus status);
}
